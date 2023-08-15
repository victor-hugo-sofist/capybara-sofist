Feature: Ticker e nomes de empresas

  Background:
    Given quee enviamos uma requisição para consultar as ações contidas no endpoint stocks
    Scenario Outline: Consultando uma ação no microsserviço
        When filtramos pela empresa com nome "<nome>"
        Then devemos encontrar detalhes com o nome da empresa junto ao seu ticker "<ticker>"
        
        Examples:
        | nome               | ticker |
        | VALE               | VALE3  |
        | ITAU               | ITUB6  |

