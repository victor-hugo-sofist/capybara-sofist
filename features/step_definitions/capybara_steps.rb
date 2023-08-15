require 'pry'
require 'json'
require_relative '../../src/requests/http_requests.rb'

Dado("que enviamos uma requisição para consultar as ações contidas no endpoint stocks") do


  Log.step_info("Dado que enviamos uma requisição para consultar as ações contidas no endpoint stocks")
  @response = HTTPRequests.retryable_get_based_in_status_code('http://192.168.0.40:5000/stocks/', 200, body: JSON.generate({ Name: 'TEST CORPORATION', Symbol: 'TEST4', Price: 299.99 }), headers: { 'Content-Type' => 'application/json' })


end

Quando("filtramos pela empresa com nome {string}") do |name|

  Log.step_info("filtramos pela empresa com nome #{name}")

  parsed_data = JSON.parse(@response.body)

  @result = nil 
  parsed_data['Content']['Stocks'].each do |stock|
      if stock['Name'] == name
          @result = stock 
          break
      end
  end
end

Então("devemos encontrar detalhes com o nome da empresa junto ao seu ticker {string}") do | ticker |
  Log.step_info("devemos encontrar detalhes com o nome da empresa junto ao seu ticker #{ticker}")
  
  begin
    expect(@result). not_to be_nil
    expect(@result['Symbol']). to eql(ticker)
  rescue
    RSpec::Expectations::ExpectationNotMetError => e
    Log.step_error(e.message)
    raise e
  end
end

Dado("quee enviamos uma requisição para consultar as ações contidas no endpoint stocks") do

  
  Log.step_error("Dado que enviamos uma requisição para consultar as ações contidas no endpoint stocks")
  @response = HTTPRequests.retryable_get_based_in_status_code('http://192.168.0.40:5000/stocks/', 201, body: JSON.generate({ Name: 'TEST CORPORATION', Symbol: 'TEST4', Price: 299.99 }), headers: { 'Content-Type' => 'application/json' })


end