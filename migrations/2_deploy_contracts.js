const SimpleStorage = artifacts.require("./SimpleStorage.sol");
const SubCurrency = artifacts.require("./SubCurrency.sol");
const Ballot = artifacts.require("./Ballot.sol");
const SimpleOpenAuction = artifacts.require("./SimpleOpenAuction.sol");

// http://truffle.readthedocs.io/en/beta/getting_started/migrations/
module.exports = function(deployer) {
  deployer.deploy(SimpleStorage);
  deployer.deploy(SubCurrency);
  deployer.deploy(Ballot);
  deployer.deploy(SimpleOpenAuction);
};
