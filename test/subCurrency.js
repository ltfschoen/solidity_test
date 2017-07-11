// References:
// - https://github.com/Sergeon/ethereum-truffle-solidity-ballot-contract/blob/master/test/ballot.js

const expect = require('chai').expect;

const SubCurrency = artifacts.require("./SubCurrency.sol");
// const listenForSentEvent = require("../scripts/listenForSentEvent.js");

const log = console.log;

contract('SubCurrency', function(accounts) {

  let subCurrencyInstance = null;
  let user1 = accounts[0];
  let user2 = accounts[1];
  let amountToTransfer = 100;
  let initialBalanceUser1 = null;
  let initialBalanceUser2 = null;
  let balanceUser1 = null;
  let balanceUser2 = null;

  before(function(done){
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
