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

  let existingSubCurrencyInstance = null;
  let user1 = null;
  let user2 = null;
  let amountToTransfer = 100;
  let initialBalanceUser1 = null;
  let initialBalanceUser2 = null;
  let balanceUser1 = null;
  let balanceUser2 = null;
  let eventSentSubCurrency = null;
  let eventForSent = false;
  let eventListenerReceived = false;

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

  console.log(`Ether conversion: 1 Ether is ${web3.toWei(1, "ether")} Wei`);

  // Asynchronously load user accounts created on TestRPC by running `bash testrpc.sh`
  before(function(done) {
    web3.eth.getAccounts(function(err, accs) {
      accounts = accs;

      user1 = accounts[0];
      user2 = accounts[1];
      console.log("Accounts: ", accs);

      done(err);
    });
  });

  console.log("Web3 provider connected: ", provider.isConnected());

  after(function(done){
    done();
  });

  before(function(done){
    SubCurrency.setProvider(provider);

    // Previously Deployed Contract Abstraction
    SubCurrency.deployed()
      .then(function(instance) {
        console.log("Previously Deployed Contract Abstraction Instance Address: ", instance.address);
        existingSubCurrencyInstance = instance;

        eventSentSubCurrency = existingSubCurrencyInstance.SentSubCurrency();

        // Event Listener "blockchain explorer" to track coin transactions and balances
        eventSentSubCurrency.watch(function(error, result) {
          if (!error) {
            eventListenerReceived = true;
            console.log("SubCurrency transfer: " + result.args.amount +
              " coins were sent from " + result.args.from +
              " to " + result.args.to + ".");
          }
        });

        return existingSubCurrencyInstance.getBalance.call(user1);
      })
      .then(function(balance) {
        initialBalanceUser1 = balance.toNumber();
        balanceUser1 = balance.toNumber();
        console.log("balanceUser1: ", balanceUser1);
      })
      .then(function() {
        return existingSubCurrencyInstance.getBalance.call(user2);
      })
      .then(function(balance) {
        initialBalanceUser2 = balance.toNumber();
        balanceUser2 = balance.toNumber();
        console.log("balanceUser2: ", balanceUser2);
      })
      .then(function() {
        // "TRANSACTION"
        //   - Note: Special 3rd parameter allows editing specific details about the transaction
        //   - Reference: http://truffleframework.com/docs/getting_started/contracts
        return existingSubCurrencyInstance.sendSubCurrency(accounts[1], amountToTransfer, {from: accounts[0]});
      })
      .then(function(transaction) {
        // "EVENT"
        //   - Reference: http://truffleframework.com/docs/getting_started/contracts
        console.log("Transaction successfully processed");

        // console.log("Resultant Transaction: ", transaction);

        // transaction is an object with the following values:
        //
        // transaction.tx      => transaction hash, string
        // transaction.logs    => array of decoded events that were triggered within this transaction
        // transaction.receipt => transaction receipt object, which includes gas used

        // Loop through result.logs to check if triggered the Transfer event.
        for (let i = 0; i < transaction.logs.length; i++) {
          let log = transaction.logs[i];

          if (log.event == "SentSubCurrency") {
            // Event found!
            eventForSent = true;
            break;
          }
        }
      })
      .then(function() {
        // "CALL"
        //   - Reference: http://truffleframework.com/docs/getting_started/contracts
        return existingSubCurrencyInstance.getBalance.call(user1);
      })
      .then(function(balance) {
        balanceUser1 = balance.toNumber();
        console.log("balanceUser1: ", balanceUser1);
      })
      .then(function() {
        return existingSubCurrencyInstance.getBalance.call(user2);
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

  let newSubCurrencyInstance = null;

  before(function(done){

    // Add New Contract Abstraction to the network
    //   - http://truffleframework.com/docs/getting_started/contracts
    SubCurrency.new()
      .then(function(instance) {
        newSubCurrencyInstance = instance;
        console.log("Newly Deployed Contract Abstraction Instance Address: ", instance.address);
        return newSubCurrencyInstance.getBalance.call(user1);
      })
      .then(function(balance) {
        console.log("balanceUser1: ", balanceUser1);
      })
      .then(function() {
        return newSubCurrencyInstance.getBalance.call(user2);
      })
      .then(function(balance) {
        console.log("balanceUser2: ", balanceUser2);
      })
      // // NOT WORKING
      // .then(function() {
      //   // Send Ether directly to trigger Fallback Function
      //   //   - References:
      //   //     - https://github.com/trufflesuite/truffle-contract/blob/master/dist/truffle-contract.js
      //   //     - https://github.com/ethereum/go-ethereum/wiki/Sending-ether
      //   newSubCurrencyInstance.sendTransaction({from: user1, to: newSubCurrencyInstance.address, value: 100});
      //   // newSubCurrencyInstance.send(web3.toWei(1, "ether"));
      // })
      // .then(function(transaction) {
      //   console.log(transaction);
      //   return newSubCurrencyInstance.getBalance.call(user1);
      // })
      // .then(function(balance) {
      //   console.log("balanceUser1: ", balance);
      // })
      .catch(function(e){
        console.log("Error: ", e);
      })
      .then(done);
  });

  it("Previously deployed subCurrency instance should exist" , function(){
    expect(existingSubCurrencyInstance).to.not.equal(null);
  } );

  it("user1 should be coinbase" , function(){
    expect(user1).to.be.equal(accounts[0]);
  });

  it("should send coins between accounts", function() {
    expect(initialBalanceUser1 - amountToTransfer).to.be.equal(balanceUser1);
    expect(initialBalanceUser2 + amountToTransfer).to.be.equal(balanceUser2);
  });

  it("should trigger SentSubCurrency event when send coins between accounts", function() {
    expect(eventForSent).to.be.equal(true);
  });

  it("event listener watching event SentSubCurrency should be triggered when send coins between accounts", function() {
    expect(eventListenerReceived).to.be.equal(true);
    eventSentSubCurrency.stopWatching();
  });

  it("creates Newly Deployed Contract Abstraction with different address to that Previously Deployed", function() {
    let previouslyDeployedContractAddress = SubCurrency.at(existingSubCurrencyInstance.address);
    let newlyDeployedContractAddress = SubCurrency.at(newSubCurrencyInstance.address);

    expect(newlyDeployedContractAddress).to.not.be.equal(previouslyDeployedContractAddress);
  });
});
