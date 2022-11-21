var Migrations = artifacts.require("./Migrations.sol");
var RedePostos = artifacts.require('./RedePostos.sol');

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(RedePostos);
};
