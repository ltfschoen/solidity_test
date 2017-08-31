const SimpleStorage = artifacts.require("./SimpleStorage.sol");
const SubCurrency = artifacts.require("./SubCurrency.sol");
const Ballot = artifacts.require("./Ballot.sol");
const SimpleOpenAuction = artifacts.require("./SimpleOpenAuction.sol");
const BlindAuction = artifacts.require("./BlindAuction.sol");
const SafeRemotePurchase = artifacts.require("./SafeRemotePurchase.sol");
const MicropaymentChannel = artifacts.require("./MicropaymentChannel.sol");
const ComplexDataStorage = artifacts.require("./ComplexDataStorage.sol");
const ArrayContract = artifacts.require("./ArrayContract.sol");
const CrowdFunding = artifacts.require("./CrowdFunding.sol");
const Template = artifacts.require("./Template.sol");

// http://truffle.readthedocs.io/en/beta/getting_started/migrations/
module.exports = function(deployer) {
  deployer.deploy(SimpleStorage);
  deployer.deploy(SubCurrency);
  deployer.deploy(Ballot);
  deployer.deploy(SimpleOpenAuction);
  deployer.deploy(BlindAuction);
  deployer.deploy(SafeRemotePurchase);
  deployer.deploy(MicropaymentChannel);
  deployer.deploy(Template);
  deployer.deploy(ComplexDataStorage);
  deployer.deploy(ArrayContract);
  deployer.deploy(CrowdFunding);
};
