const SimpleStorage = artifacts.require("./SimpleStorage.sol");
const SubCurrency = artifacts.require("./SubCurrency.sol");

module.exports = function(deployer) {
  deployer.deploy(SimpleStorage)
    .then(function() {
      return deployer.deploy(SubCurrency);
    });
};
