Feature: Exemplo de teste com Capybara com cucumber

  Background:
    Given que enviamos uma requisição para consultar as ações contidas no endpoint stocks
    Scenario Outline: Consultando uma ação no microsserviço
        When filtramos pela empresa com nome "<nome>"
        Then devemos encontrar detalhes com o nome da empresa junto ao seu ticker "<ticker>"
        
        Examples:
        | nome             | ticker |
        | VALE             | VALE3  |
        | ITAU             | ITUB4  |
        | CSN MINERACAO    | CMIN3  |
        | MAXI RENDA       | MXRF11 |
        | ITI BANCO DIGITAL| ITIU4  |
        | ABCD CORPORATION | ABCD4  |
