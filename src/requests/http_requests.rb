require 'httparty'
require 'json'
require 'jsonpath'
require 'logger'
require 'date'

class Unexpected_status_code < StandardError
end

class Json_path_without_results < StandardError
end

class Unexpected_request_method < StandardError
end

class HTTPMethod
  GET = "GET"
  POST = "POST"
  DELETE = "DELETE"
  PATCH = "PATCH"
end

class Log

  current_time = DateTime.now
  formatted_time = current_time.strftime('%d-%m-%Y_%Hh%Mm%Ss')
  log_file_path = "logs/log_#{formatted_time}.log"
  file = File.open(log_file_path, File::WRONLY | File::APPEND | File::CREAT)
  @log = Logger.new(file)

  def self.test_end ()
    @log.debug ("TEST END") { "\n\n" }
  end

  def self.theme_and_info (theme, content)
    @log.info (theme) { content }
  end

  def self.theme_and_debug (theme, content)
    @log.debug (theme) { content }
  end
  
  def self.step_info (content)
    @log.info ("Step") { content }
  end

  def self.step_debug (content)
    @log.debug ("Step") { content }
  end

  def self.step_error (message, backtrace)

    message = message.sub("\n", "\n   ")
    backtrace = backtrace.join("\n   ")

    @log.error ("Message") { message }
    @log.error ("Backtrace") { backtrace }

  end

  def self.request_info (url, content)
    @log.info ("Request URL: " + url) { content }
  end

  def self.request_error (url, content)
    @log.error ("Request URL: " + url) { content }
  end

  def self.request_warn (url, content)
    @log.warn ("Request URL: " + url) { content }
  end

  def self.request_fatal (url, content)
    @log.fatal ("Request URL: " + url) { content }
  end

  def self.format_request_info (payload, response_body, status_code, request_method)
  
    if payload.nil?
      payload = 'nil'
    end

    payload = payload.strip
    
    if payload.empty?
      payload = 'nil'
    end

    if  response_body.nil?
      response_body = 'nil'
    end
  
    response_body = response_body.strip
    
    if response_body.empty?
      response_body = 'nil'
    end
  
    content = "\n   Request Method: #{request_method}\n   Status Code: #{status_code}\n   Payload: #{payload}\n   Response: #{response_body}"
    return content
  end
end

class HTTPRequests
  include HTTParty

  MAX_RETRIES = 2
  RETRY_INTERVAL = 2 # Em segundos, pode ser ajustado conforme a necessidade

  def self.retryable_based_in_status_code(url, method, expected_status_code, options = {})

    request_method = nil
    retries = 0
    response = nil

    begin

      case method
      when HTTPMethod::GET
        request_method = HTTPMethod::GET
        response = get(url, options)
      when HTTPMethod::POST
        request_method = HTTPMethod::POST
        response = post(url, options)
      when HTTPMethod::DELETE
        request_method = HTTPMethod::DELETE
        response = delete(url, options)
      when HTTPMethod::PATCH
        request_method = HTTPMethod::PATCH
        response = patch(url, options)
      else
        raise Unexpected_request_method
      end
      
      Log.request_info(url, Log.format_request_info(options[:body], response.body, response.code, request_method))
      if response.code != expected_status_code
        raise Unexpected_status_code, "The expected status code is #{expected_status_code}, but received #{response.code}"
      end
      return response
    rescue StandardError => e
      Log.request_warn(url, e.message)
      retries += 1
      if retries <= MAX_RETRIES
        Log.request_info(url,"Retry the request (Attempt #{retries}). Trying again in #{RETRY_INTERVAL} second(s)...")
        sleep(RETRY_INTERVAL)
        retry
      else
        Log.request_error(url,"Failed after #{MAX_RETRIES} attempts.\n   Error: #{e.message}\n   Backtrace: #{e.backtrace.join("\n   ")}")
        Log.test_end()
        raise "Failed after #{MAX_RETRIES} attempts. Error: #{e.message}"
      end
    end
  end
 
  def self.retryable_based_in_json_path(url, method, json_path_filter, options = {})

    request_method = nil
    retries = 0
    response = nil

    begin
      
      case method
      when HTTPMethod::GET
        request_method = HTTPMethod::GET
        response = get(url, options)
      when HTTPMethod::POST
        request_method = HTTPMethod::POST
        response = post(url, options)
      when HTTPMethod::DELETE
        request_method = HTTPMethod::DELETE
        response = delete(url, options)
      when HTTPMethod::PATCH
        request_method = HTTPMethod::PATCH
        response = patch(url, options)
      else
        raise Unexpected_request_method
      end

      Log.request_info(url, Log.format_request_info(options[:body], response.body, response.code, request_method))
      value = find_value_by_path(response.body, json_path_filter)
      if !value.empty?
        Log.request_info(url, "JSON path result: #{value}")
        return response
      end
      Log.request_info(url, "JSON path result: nil")
      raise Json_path_without_results
    rescue StandardError => e
      Log.request_warn(url, e.message)
      retries += 1
      if retries <= MAX_RETRIES
        Log.request_info(url,"Retry the request (Attempt #{retries}). Trying again in #{RETRY_INTERVAL} second(s)...")
        sleep(RETRY_INTERVAL)
        retry
      else
        Log.request_error(url,"Failed after #{MAX_RETRIES} attempts.\n   Error: #{e.message}\n   Backtrace: #{e.backtrace.join("\n   ")}")
        Log.test_end()
        raise "Failed after #{MAX_RETRIES} attempts: Error: #{e.message}"
      end
    end
  end

  private

  def self.find_value_by_path(json_data, path)
    parsed_data_json = JSON.parse(json_data)
    json_path = JsonPath.new(path)
    result = json_path.on(parsed_data_json)
    return result
  end
end