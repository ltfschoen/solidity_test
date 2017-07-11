// References:
// - https://github.com/Sergeon/ethereum-truffle-solidity-ballot-contract/blob/master/test/ballot.js
// - https://github.com/trufflesuite/truffle-artifactor/blob/master/test/contracts.js
// - http://web3js.readthedocs.io/en/1.0/web3-eth.html
// - https://github.com/ethereum/web3.js/blob/master/example/contract_array.html

const TestRPC = require("ethereumjs-testrpc");
const Web3 = require("web3");

const expect = require('chai').expect;

const SubCurrency = artifacts.require("./SubCurrency.sol");
// const listenForSentEvent = require("../scripts/listenForSentEvent.js");

const log = console.log;

contract('SubCurrency', function(accounts) {

  let subCurrencyInstance = null;
  let user1 = null;
  let user2 = null;
  let amountToTransfer = 100;
  let initialBalanceUser1 = null;
  let initialBalanceUser2 = null;
  let balanceUser1 = null;
  let balanceUser2 = null;

  // // https://github.com/ethereumjs/testrpc
  // let accountConfig = {
  //   "accounts": [
  //     { '0x0000000000000000000000000000000000000000000000000000000000000001': '10002471238800000000000' },
  //     { '0x0000000000000000000000000000000000000000000000000000000000000002': '10004471238800000000000' },
  //     { '0x7e5f4552091a69125d5dfcb7b8c2659029395bdf': '10000000000000000000000'},
  //     { '0x2b5ad5c4795c026514f8317c7a215e218dccd6cf': '10000000000000000000000'}
  //   ],
  //   "unlocked_accounts": [
  //     '0x0000000000000000000000000000000000000000000000000000000000000001',
  //     '0x0000000000000000000000000000000000000000000000000000000000000002',
  //     '0x7e5f4552091a69125d5dfcb7b8c2659029395bdf',
  //     '0x2b5ad5c4795c026514f8317c7a215e218dccd6cf'
  //   ],
  //   "network_id": 'development',
  //   "locked": true,
  //   "port": 8545,
  //   "debug": true,
  //   "db_path": './db/chaindb'
  // };

  const web3 = new Web3();

  // // NOTE: THIS APPROACH GIVES ERROR `Error: could not unlock signer account`
  // let provider = TestRPC.provider({accountConfig});

  // IMPORTANT: Ensure already launched TestRPC with `bash testrpc.sh`
  let provider = new web3.providers.HttpProvider("http://localhost:8545");

  // TestRPC used as Web3 Provider
  web3.setProvider(provider);

  log(`Ether conversion: 1 Ether is ${web3.toWei(1, "ether")} Wei`);

  // Asynchronously load the user accounts that were created on TestRPC
  // by running `bash testrpc.sh`
  before(function(done) {
    web3.eth.getAccounts(function(err, accs) {
      accounts = accs;

      user1 = accounts[0];
      user2 = accounts[1];
      log("Accounts: ", accs);

      done(err);
    });
  });

  log("Web3 provider connected: ", provider.isConnected());

  before(function(done){
    SubCurrency.setProvider(provider);
    SubCurrency.deployed()
      .then(function(instance) {
        subCurrencyInstance = instance;
        return subCurrencyInstance.getBalance.call(user1);
      })
      .then(function(balance) {
        initialBalanceUser1 = balance.toNumber();
        balanceUser1 = balance.toNumber();
        console.log("balanceUser1: ", balanceUser1);
      })
      .then(function() {
        return subCurrencyInstance.getBalance.call(user2);
      })
      .then(function(balance) {
        initialBalanceUser2 = balance.toNumber();
        balanceUser2 = balance.toNumber();
        console.log("balanceUser2: ", balanceUser2);
      })
      .then(function() {
        return subCurrencyInstance.sendSubCurrency(accounts[1], amountToTransfer);
      })
      .then(function() {
        return subCurrencyInstance.getBalance.call(user1);
      })
      .then(function(balance) {
        balanceUser1 = balance.toNumber();
        console.log("balanceUser1: ", balanceUser1);
      })
      .then(function() {
        return subCurrencyInstance.getBalance.call(user2);
      })
      .then(function(balance) {
        balanceUser2 = balance.toNumber();
        console.log("balanceUser2: ", balanceUser2);
      })
      .catch(function(e){
        console.log("Error: ", e);
      })
      .then(done);
  });

  it("subCurrency instance should be deployed" , function(){
    expect(subCurrencyInstance).to.not.equal(null);
  } );

  it("user1 should be coinbase" , function(){
    expect(user1).to.be.equal(accounts[0]);
  });

  it("should send coins between accounts", function() {
    expect(initialBalanceUser1 - amountToTransfer).to.be.equal(balanceUser1);
    expect(initialBalanceUser2 + amountToTransfer).to.be.equal(balanceUser2);
  });

});
