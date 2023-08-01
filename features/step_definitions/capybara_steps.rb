require 'pry'
require 'httparty'
require 'json'

Dado("que enviamos uma requisição para consultar as ações contidas no endpoint stocks") do

  @response = HTTParty.get('http://192.168.0.40:5000/stocks/')

end

Quando("filtramos pela empresa com nome {string}") do |name|

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

  expect(@result). not_to be_nil
  expect(@result['Symbol']). to eql(ticker)

end