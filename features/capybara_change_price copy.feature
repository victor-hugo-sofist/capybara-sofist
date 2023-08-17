Feature: Alterando preços de ações

  Background:
    Given que enviamos uma requisição para alterar o preço de uma ação com ticker CHNG3
    Given que enviamos uma requisição para consultar as ações contidas no endpoint stocks
    Scenario Outline: Consultando uma ação no microsserviço
        When filtramos pela empresa com nome "<nome>"
        Then devemos alterar o preço com base em um valor aleatório
      
      Examples:
      | nome                           |
      | CHANGE PRICE CORPORATION       |
