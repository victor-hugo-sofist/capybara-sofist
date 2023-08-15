Feature: Ticker e nomes de empresas

  Background:
    Given que enviamos uma requisição para consultar as ações contidas no endpoint stocks
    Scenario Outline: Consultando uma ação no microsserviço
        When filtramos pela empresa com nome "<nome>"
        Then devemos encontrar detalhes com o nome da empresa junto ao seu ticker "<ticker>"
        
        Examples:
        | nome               | ticker |
        | VALE               | VALE3  |
        | ITAU               | ITUB4  |
        | CSN MINERACAO      | CMIN3  |
        | MAXI RENDA         | MXRF11 |
        | ITI BANCO DIGITAL  | ITIU4  |
        | ITI BANCO DIGITAL  | ITIU11 |
    Scenario Outline: Consultando uma ação no microsserviço
      When filtramos pela empresa com nome "<nome>"
      Then devemos encontrar detalhes com o nome da empresa junto ao seu ticker "<ticker>"
      
      Examples:
      | nome               | ticker |
      | VALE               | VALE4  |
      | ITAU               | ITUB3  |
      | CSN MINERACAO      | CMIN4  |


