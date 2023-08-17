Feature: Preço das ações e nomes de empresas

  Background:
    Given que enviamos uma requisição para consultar as ações contidas no endpoint stocks
    Scenario Outline: Consultando uma ação no microsserviço
        When filtramos pela empresa com nome "<nome>"
        Then devemos encontrar detalhes com o nome da empresa junto ao seu preço de <price>
      
      Examples:
      | nome               |  price |
      | VALE               |  20.5  |
      | ITAU               |  26.02 |
      | CSN MINERACAO      |   2.53 |
      | MAXI RENDA         |  10.17 |
      | ITI BANCO DIGITAL  |  10.01 |