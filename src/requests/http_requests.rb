require 'httparty'
require 'json'
require 'jsonpath'
require 'logger'

class Unexpected_status_code < StandardError
end

class Json_path_without_results < StandardError
end

class Log

  file = File.open('logs/test_logs.log', File::WRONLY | File::APPEND | File::CREAT)
  @log = Logger.new(file)

  def self.step_info (content)
    @log.info ("Step") { content }
  end

  def self.step_error (content)
    @log.info ("Then") { content }
  end

  def self.request_info (url, method, content)
    @log.info ("URL: " + url + " -- Method: " + method) { content }
  end

  def self.request_error (url, method, content)
    @log.error ("URL: " + url + " -- Method: " + method) { content }
  end

  def self.request_warn (url, method, content)
    @log.warn ("URL: " + url + " -- Method: " + method) { content }
  end

  def self.request_fatal (url, method, content)
    @log.fatal ("URL: " + url + " -- Method: " + method) { content }
  end

  def self.format_payload (payload)
    payload = payload.strip
    if payload.empty?
      payload = 'nil'
    end
    
    content = "\n   Payload: #{payload}"
    return content
  end

  def self.format_response_body (response_body, status_code)
  response_body = response_body.strip
  if response_body.empty?
    response_body = 'nil'
  end

  content = "\n   Response: #{response_body}\n   Status code: #{status_code}"
  return content
  end
end

class HTTPRequests
  include HTTParty

  MAX_RETRIES = 2
  RETRY_INTERVAL = 2 # Em segundos, pode ser ajustado conforme a necessidade

  def self.retryable_get_based_in_status_code(url, expected_status_code, options = {})
    get_method = 'GET'
    retries = 0
    begin
      Log.request_info(url, get_method, Log.format_payload(options[:body]))
      response = get(url, options)
      Log.request_info(url, get_method, Log.format_response_body(response.body, response.code))
      if response.code != expected_status_code
        # Log.request_warn(url, get_method, "The expected status code is #{expected_status_code}, but received #{response.code}")
        raise Unexpected_status_code, "The expected status code is #{expected_status_code}, but received #{response.code}"
      end
      return response
    rescue StandardError => e
      Log.request_warn(url, get_method, e.message)
      retries += 1
      if retries <= MAX_RETRIES
        Log.request_info(url, get_method,"Retry the request (Attempt #{retries}). Trying again in #{RETRY_INTERVAL} second(s)...")
        sleep(RETRY_INTERVAL)
        retry
      else
        Log.request_error(url, get_method,"Failed after #{MAX_RETRIES} attempts.\n   Error: #{e.message}\n   Backtrace: #{e.backtrace}")
        raise "Failed after #{MAX_RETRIES} attempts. Error: #{e.message}"
      end
    end
  end

  def self.retryable_post_based_in_status_code(url, expected_status_code, options = {})
    retries = 0
    begin
      response = post(url, options)
      if response.code != expected_status_code
        raise Unexpected_status_code, "The expected status code is #{expected_status_code}, but received #{response.code}"
      end
      return response
    rescue StandardError => e
      retries += 1
      if retries <= MAX_RETRIES
        puts "Error in the request (Attempt #{retries}). Trying again in #{RETRY_INTERVAL} second(s)..."
        sleep(RETRY_INTERVAL)
        retry
      else
        raise "Failed after #{MAX_RETRIES} attempts: Error: #{e.message}"
      end
    end
  end

  def self.retryable_delete_based_in_status_code(url, expected_status_code, options = {})
    retries = 0
    begin
      response = delete(url, options)
      if response.code != expected_status_code
        raise Unexpected_status_code, "The expected status code is #{expected_status_code}, but received #{response.code}"
      end
      return response
    rescue StandardError => e
      retries += 1
      if retries <= MAX_RETRIES
        puts "Error in the request (Attempt #{retries}). Trying again in #{RETRY_INTERVAL} second(s)..."
        sleep(RETRY_INTERVAL)
        retry
      else
        raise "Failed after #{MAX_RETRIES} attempts: Error: #{e.message}"
      end
    end
  end

  def self.retryable_patch_based_in_status_code(url, expected_status_code, options = {})
    retries = 0
    begin
      response = patch(url, options)
      if response.code != expected_status_code
        raise Unexpected_status_code, "The expected status code is #{expected_status_code}, but received #{response.code}"
      end
      return response
    rescue StandardError => e
      retries += 1
      if retries <= MAX_RETRIES
        puts "Error in the request (Attempt #{retries}). Trying again in #{RETRY_INTERVAL} second(s)..."
        sleep(RETRY_INTERVAL)
        retry
      else
        raise "Failed after #{MAX_RETRIES} attempts: Error: #{e.message}"
      end
    end
  end

  def self.retryable_get_if_has_json_path(url, json_path_filter, options = {})
    retries = 0
    begin
      response = get(url, options)
      value = find_value_by_path(response.body, json_path_filter)
      if !value.empty?
        return response
      end
      raise Json_path_without_results
    rescue StandardError => e
      retries += 1
      if retries <= MAX_RETRIES
        puts "Error in the request or JSON path yielded no results. (Attempt #{retries}). Trying again in #{RETRY_INTERVAL} second(s)..."
        sleep(RETRY_INTERVAL)
        retry
      else
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