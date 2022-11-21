const RedePostos = artifacts.require("RedePostos");

contract("RedePostos", function (accounts) {
  it("should return correct test", async function () {
    const deployed = await RedePostos.deployed();
    
    const enderecoOwner = accounts[0];
    const enderecoPosto = accounts[1];
    const enderecoCliente = accounts[2];
    
    await deployed.adicionarSaldo(enderecoPosto, 10000, {from: enderecoOwner});
    await deployed.adicionarSaldo(enderecoCliente, 10000, {from: enderecoOwner});
    await deployed.registrarPosto(1,     2, 10, 1000, {from: enderecoPosto});
    await deployed.registrarPosto(100, 200,  2, 1000, {from: enderecoPosto});
    await deployed.registrarPosto(1,     2,  5, 1000, {from: enderecoPosto});
    await deployed.localizarMelhorOferta(1, 2, 10, {from: enderecoCliente});
    await deployed.comprarCombustivel(3, 20, {from: enderecoCliente});
    assertTrue(false);
  });
});
