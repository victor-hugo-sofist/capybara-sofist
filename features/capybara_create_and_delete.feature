Feature: Criando e deletando um produto financeiro

  Scenario: Criando e deletando produtos financeiro NEEW3
    Given que criamos um novo produto financeiro NEEW3
    When consultamos o endpoint stock procurando pelo produto produto financeiro NEEW3 devemos obter o status 200
    When deletamos o produto NEEW3
    When consultamos o endpoint stock procurando pelo produto produto financeiro NEEW3 devemos obter o status 400
    Then o produto não deve mais constar na base de dados
    