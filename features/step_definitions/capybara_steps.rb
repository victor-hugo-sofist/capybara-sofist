require 'pry'
require 'json'
require_relative '../../src/requests/http_requests.rb'

Dado("que enviamos uma requisição para consultar as ações contidas no endpoint stocks") do

  Log.step_debug("Dado que enviamos uma requisição para consultar as ações contidas no endpoint stocks")
  @response = HTTPRequests.retryable_get_based_in_status_code('http://192.168.0.40:5000/stocks/', 200, headers: { 'Content-Type' => 'application/json' })

end

Quando("filtramos pela empresa com nome {string}") do |name|

  Log.step_debug("Quando filtramos pela empresa com nome #{name}")

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
  Log.step_debug("Então devemos encontrar detalhes com o nome da empresa junto ao seu ticker #{ticker}")

  begin
    expect(@result). not_to be_nil
    expect(@result['Symbol']). to eql(ticker)
  rescue RSpec::Expectations::ExpectationNotMetError => e
    Log.step_error(e.message, e.backtrace)
    raise e
  end
end

Dado("quee enviamos uma requisição para consultar as ações contidas no endpoint stocks") do

  
  Log.step_debug("Dado que enviamos uma requisição para consultar as ações contidas no endpoint stocks")
  @response = HTTPRequests.retryable_get_based_in_status_code('http://192.168.0.40:5000/stocks/', 201, body: JSON.generate({ Name: 'TEST CORPORATION', Symbol: 'TEST4', Price: 299.99 }), headers: { 'Content-Type' => 'application/json' })


end

Então("devemos encontrar detalhes com o nome da empresa junto ao seu preço de {float}") do | price |
  Log.step_debug("Então devemos encontrar detalhes com o nome da empresa junto ao seu preço de #{price}")
  begin
    expect(@result). not_to be_nil
    expect(@result['Price']).to be == price
  rescue RSpec::Expectations::ExpectationNotMetError => e
    Log.step_error(e.message, e.backtrace)
    raise e
  end
end

Dado("que enviamos uma requisição para alterar o preço de uma ação com ticker CHNG3") do

  max = 100
  min = 1
  @random_price = (min + rand * (max - min)) * 100
  @random_price = @random_price.round / 100.0
  
  Log.step_debug("Dado que enviamos uma requisição para alterar o preço de uma ação com ticker CHNG3")
  @response = HTTPRequests.retryable_patch_based_in_status_code('http://192.168.0.40:5000/stock/CHNG3/change/price/', 202, headers: { 'Content-Type' => 'application/json' }, body: JSON.generate( { "Price": @random_price } ))

end

Então("devemos alterar o preço com base em um valor aleatório") do
  Log.step_debug("Então devemos alterar o preço com base em um valor aleatório de #{@random_price}")
  begin
    expect(@result). not_to be_nil
    expect(@result['Price']).to be == @random_price
  rescue RSpec::Expectations::ExpectationNotMetError => e
    Log.step_error(e.message, e.backtrace)
    raise e
  end
end

Dado("que criamos um novo produto financeiro NEEW3") do
  
  Log.step_debug("Dado que criamos um novo produto financeiro NEEW3")
  @response = HTTPRequests.retryable_post_based_in_status_code('http://192.168.0.40:5000/new/stock/', 201, headers: { 'Content-Type' => 'application/json' }, body: JSON.generate({
    "Name": "NEEW CORPORATION",
    "Symbol": "NEEW3",
    "Price": 9.99
  }))

end

Quando("consultamos o endpoint stock procurando pelo produto produto financeiro NEEW3 devemos obter o status 200") do

  Log.step_debug("Quando consultamos o endpoint stock procurando pelo produto produto financeiro NEEW3 devemos obter o status 200")
  @response = HTTPRequests.retryable_get_based_in_status_code('http://192.168.0.40:5000/stock/NEEW3/', 200, headers: { 'Content-Type' => 'application/json' })

end

Quando("consultamos o endpoint stock procurando pelo produto produto financeiro NEEW3 devemos obter o status 400") do

  Log.step_debug("Quando consultamos o endpoint stock procurando pelo produto produto financeiro NEEW3 devemos obter o status 400")
  @response = HTTPRequests.retryable_get_based_in_status_code('http://192.168.0.40:5000/stock/NEEW3/', 400, headers: { 'Content-Type' => 'application/json' })

end

Quando ("deletamos o produto NEEW3") do

  Log.step_debug("Quando deletamos o produto NEEW3")
  @response = HTTPRequests.retryable_delete_based_in_status_code('http://192.168.0.40:5000/stock/delete/NEEW3/', 200, headers: { 'Content-Type' => 'application/json' })

end

Então("o produto não deve mais constar na base de dados") do

  Log.step_debug("o produto não deve mais constar na base de dados")
  @response = HTTPRequests.retryable_get_based_in_status_code('http://192.168.0.40:5000/stock/NEEW3/', 400, headers: { 'Content-Type' => 'application/json' })
  begin
    expect(@response.code).to be == 400
  rescue RSpec::Expectations::ExpectationNotMetError => e
    Log.step_error(e.message, e.backtrace)
    raise e
  end
end
