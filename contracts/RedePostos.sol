// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract RedePostos {
  struct Posto {
    uint id;
    uint coordX;
    uint coordY;
    uint valor;       // em centavos, por mililitro
    uint estoque;     // em mililitros
    address endereco;
  }

  uint numeroPostos;
  mapping(uint => Posto) public postos;
  mapping(address => uint) public saldos;
  address public criador;

  error EstoqueInsuficiente(uint quantidadeSolicitada, uint quantidadeDisponivel);
  error SaldoInsuficiente(uint saldoNecessario, uint saldoDisponivel);

  event AbastecimentoLiberado(address enderecoPosto, uint quantidadeLiberada, uint valorTotal);
  event MelhorOfertaEncontrada(address enderecoCliente, uint idMelhorPosto, uint melhorValor, address enderecoPosto);
  event EstoqueReposto(address enderecoPosto, uint quantidadeReposta);
  event NovoSaldo (address destinatario, uint quantidade);
  event NovoIdDePosto (uint id);

  constructor() {
      criador = msg.sender;
  }

  function digaOla() public pure returns (string memory) {
      return "Ola, mundo!";
  }

  function adicionarSaldo(address destinatario, uint quantidade) public {
      require(msg.sender == criador, "apenas criador");
      saldos[destinatario] += quantidade;
      emit NovoSaldo(destinatario, saldos[destinatario]);
  }

  function registrarPosto(uint coordX, uint coordY, uint valor, uint estoque) public returns(uint) {
    uint novoIdDePosto = ++numeroPostos;

    postos[novoIdDePosto] = Posto(
        novoIdDePosto,
        coordX,
        coordY,
        valor,
        estoque,
        msg.sender
    );

    emit NovoIdDePosto(novoIdDePosto);
    return novoIdDePosto;
}

  function localizarMelhorOferta(uint coordXDoCliente, uint coordYDoCliente, uint raioDesejado) public returns(uint) {
    uint idMelhorPosto = 0;
    uint melhorValor = 0;

    for (uint i = 1; i <= numeroPostos; i++) {
        uint dx = postos[i].coordX - coordXDoCliente;
        uint dy = postos[i].coordY - coordYDoCliente;
        if (dx * dx + dy * dy <= raioDesejado * raioDesejado &&
            (idMelhorPosto == 0 || melhorValor > postos[i].valor)) {
                idMelhorPosto = postos[i].id;
                melhorValor = postos[i].valor;
        }
    }

    emit MelhorOfertaEncontrada(msg.sender, idMelhorPosto, melhorValor, postos[idMelhorPosto].endereco);

    return idMelhorPosto;
  }

  function reporEstoque(uint idPosto, uint quantidade) public {
      require(msg.sender == postos[idPosto].endereco, "funcionalidade acessivel apenas ao posto");
      postos[idPosto].estoque += quantidade;

      emit EstoqueReposto(msg.sender, quantidade);
  }

  function comprarCombustivel(uint idPosto, uint quantidadeSolicitada) public {
    if (postos[idPosto].estoque < quantidadeSolicitada) {
      revert EstoqueInsuficiente({
          quantidadeSolicitada: quantidadeSolicitada,
          quantidadeDisponivel: postos[idPosto].estoque
      });
    }

    uint valorTotal = postos[idPosto].valor * quantidadeSolicitada;

    if (saldos[msg.sender] < valorTotal) {
      revert SaldoInsuficiente({
          saldoNecessario: valorTotal,
          saldoDisponivel: saldos[msg.sender]
      });
    }

    postos[idPosto].estoque -= quantidadeSolicitada;
    saldos[msg.sender] -= valorTotal;
    saldos[postos[idPosto].endereco] += valorTotal;

    // Liberar abastecimento
    emit AbastecimentoLiberado(postos[idPosto].endereco, quantidadeSolicitada, valorTotal);
    emit NovoSaldo(msg.sender, saldos[msg.sender]);
    emit NovoSaldo(postos[idPosto].endereco, saldos[postos[idPosto].endereco]);
  }

}
