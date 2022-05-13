const Migrations = artifacts.require("Migrations");

const Token = artifacts.require('@openzeppelin/contracts/ERC20PresetMinterPauser');

module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(Token, 'LavaETH', 'LavaETH')
};