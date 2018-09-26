var BasicContract = artifacts.require("./BasicContract.sol");
var WizardManager = artifacts.require("./WizardManager.sol");
var MainContract = artifacts.require("./WizardMainContract.sol");

module.exports = function(deployer) {
    // deployer.deploy(WizardManager);
    deployer.deploy(BasicContract, {value: 100000000000000000});
    deployer.deploy(MainContract)
};
