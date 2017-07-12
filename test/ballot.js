// Reference: https://github.com/Sergeon/ethereum-truffle-solidity-ballot-contract/blob/master/test/ballot.js

const TestRPC = require("ethereumjs-testrpc");
const Web3 = require("web3");

const expect = require('chai').expect;

const Ballot = artifacts.require("./Ballot.sol");

let ballot = null;

let log = console.log;

function clearBytes32(str){
  return str.replace(/\u0000/g, '');
}

function toInteger(bigNumber){
  return parseInt(bigNumber.toString());
}

contract("Ballot" , function(accounts){

  const web3 = new Web3();

  // IMPORTANT: Ensure already launched TestRPC with `bash testrpc.sh`
  let provider = new web3.providers.HttpProvider("http://localhost:8545");

  // TestRPC used as Web3 Provider
  web3.setProvider(provider);

  console.log(`Ether conversion: 1 Ether is ${web3.toWei(1, "ether")} Wei`);

  // Asynchronously load user accounts created on TestRPC by running `bash testrpc.sh`
  before(function(done) {
    web3.eth.getAccounts(function(err, accs) {
      accounts = accs;

      console.log("Accounts: ", accs);

      done(err);
    });
  });

  describe("new()" , function(){

    let chairperson = null;
    let proposalsCount = null;
    let firstProposalName = null;

    before(function(done){

      Ballot.new(["hard fork" , "soft fork" , "do nothing"])
        .then(function(contract){
          console.log("New instance address: ", contract.address);
          ballot = contract;
          return ballot;
        })
        .then(function(){
          return ballot.chairperson();
        })
        .then(function(res){
          chairperson = res;
          return ballot.getProposalName(0);
        })
        .then(function(res){
          firstProposalName = res;
          return ballot.proposalsCount();
        })
        .then(function(response){
          proposalsCount = response;
        })
        .catch(function(e){
          console.log("Error new(): ", e);
        })
        .then(done);
    });

    it("ballot instance should exist", function(){
      expect(ballot).to.not.equal(null);
    });

    it("ballot chairperson should be coinbase", function(){
      expect(chairperson).to.be.equal(accounts[0]);
    });

    it("ballot first proposal name should be set", function(){
      let ascii = web3.toAscii(firstProposalName);
      expect(clearBytes32(ascii)).to.be.equal("hard fork");
    });

    it("ballot proposals count should be 3", function(){
      expect(parseInt(proposalsCount.toString())).to.be.equal(3);
    });
  });

  describe("vote()", function(){

    let firstProposalName = null;
    let firstProposalVoteCount = null;

    before(function(done){

      Ballot.deployed()
        .then(function(instance) {
          console.log("Deployed instance address: ", instance.address);
        })
        .then(function() {
          ballot.giveRightToVote(accounts[1])
        })
        .then(function(){
          ballot.giveRightToVote(accounts[2])
        })
        .then(function(){
          ballot.giveRightToVote(accounts[3])
        })
        .then(function(){
          ballot.giveRightToVote(accounts[4])
        })
        .then(function(){
          ballot.giveRightToVote(accounts[5])
        })
        .then(function(){
          ballot.giveRightToVote(accounts[6])
        })
        .then(function(){
          ballot.vote(0);
        })
        .then(function(){
          return ballot.getProposalName(0);
        })
        .then(function(proposal){
          firstProposalName = proposal;
          console.log("firstProposalName: ", firstProposalName);
          return ballot.getProposalVoteCount(0);
        })
        .then(function(proposal) {
          firstProposalVoteCount = proposal;
          console.log("firstProposalVoteCount: ", firstProposalVoteCount);
        })
        .catch(function(e){
          console.log("Error vote(): ", e);
        })
        .then(done);
    });

    it("First proposal should have one vote", function(){
      expect(toInteger(firstProposalVoteCount)).to.be.equal(1);
    });

  });

  describe("delegate()", function(){

    let secondProposalVoteCount = null;
    let thirdAccountWeight = -1;

    before(function(done){

      Ballot.deployed()
        .then(function(instance) {
          console.log("Deployed instance address: ", instance.address);
        })
        .then(function(){
          ballot.delegate(accounts[2], {from: accounts[1]})
        })
        .then(function(delegated){
          console.log("delegated: ", delegated);
          ballot.vote(1, {from: accounts[2]});
        })
        .then(function(){
          return ballot.getProposalVoteCount(1);
        })
        .then(function(proposal){
          secondProposalVoteCount = proposal;
          return ballot.getVoter(2);
        })
        .then(function(voter){
          thirdAccountWeight = toInteger(voter[1]);
        })
        .catch(function(e){
          console.log("Error vote(): ", e);
        })
        .then(done);
    });

    it("Second proposal now should have two votes", function(){
      expect(toInteger(secondProposalVoteCount)).to.be.equal(2);
    });

    it("Third account should have 2 weight", function(){
      expect(thirdAccountWeight).to.be.equal(2);
    });

  });

  describe("winningProposal()", function(){

    it("soft fork is the winning proposal", function(done){
      ballot.winningProposal()
        .then(function(winner){
          expect(parseInt(winner.toString())).to.be.equal(1);
        })
        .catch(function(e){
          console.log("Error vote(): ", e);
        })
        .then(done);
    });

  });

  describe("Retrieve voters data", function(){

    let votersCollectionCount = -1;

    let coinbaseVote = null;
    let coinbaseDelegatee = null;
    let coinbaseWeight = null;

    let secondVote = null;
    let secondDelegatee = null;
    let secondWeight = null;

    let thirdVote = null;
    let thirdDelegatee = null;
    let thirdWeight = null;

    before(function(done){

      ballot.votersCount()
        .then(function(count){
          votersCollectionCount = parseInt(count.toString());
        })
        .then(function(){
          // Retrieving coinbase vote data
          return ballot.getVoter(0);
        })
        .then(function(voter){
          // address, uint, bool, address, uint
          // voterAddress, voter.weight, voter.voted, voter.delegate, voter.vote
          coinbaseWeight = parseInt(voter[1].toString());
          coinbaseVote = parseInt(voter[4].toString());
          coinbaseDelegatee = parseInt(voter[3].toString());
          return ballot.getVoter(1);
        })
        .then(function(voter){
          secondWeight = toInteger(voter[1]);
          secondDelegatee = voter[3];
          return ballot.getVoter(2);
        })
        .then(function(third){
          thirdWeight = toInteger(third[1]);
          thirdVote = toInteger(third[4]);
        })
        .catch(function(e){
          console.log("Error vote(): ", e);
        })
        .then(done);
    });

    it("Number of voters should be 7", function(){
      expect(votersCollectionCount).to.be.equal(7);
    });

    it("coinbaseWeight should be 1", function(){
      expect(coinbaseWeight).to.be.equal(1);
    });

    it("coinbase vote should be first proposal", function(){
      expect(coinbaseVote).to.be.equal(0);
    });

    it("coinbase delegatee should be burn address ", function(){
      expect(coinbaseDelegatee).to.be.equal(0);
    });

    it("Second voter weight should be 1", function(){
      expect(secondWeight).to.be.equal(1);
    });

    it("Second should have been delegate to the third account", function(){
      expect(secondDelegatee).to.be.equal(accounts[2]);
    });

    it("third voter weight should be 2", function(){
      expect(thirdWeight).to.be.equal(2);
    });

    it("third voter vote should be 1", function(){
      expect(thirdVote).to.be.equal(1);
    })
  });

  describe("dynamic arrays of structs can be eperformed by recursion", function(){

    let votersData = [];

    let getNextVoterData = function(i, count){

      if(i == count){
        return ballot.getVoter(i)
          .then(function(data){
            votersData.push(data)
          })
          .catch(function(e){
            console.log("Error recursive: ", e);
          });
      }

      return ballot.getVoter(i)
        .then(function(data){
          votersData.push(data);
          return getNextVoterData(i + 1, count);
        })
        .catch(function(e){
          console.log("Error recursive voter: ", e);
        });
    };

    before(function(done){
      ballot.votersCount()
        .then(function(c){
          return getNextVoterData(0, c - 1);
        })
        .catch(function(e){
          console.log("Error recursive before: ", e);
        })
        .then(done);
    });

    it("VotersData should be filled", function(){
      expect(votersData.length).to.be.equal(7);
    });

  });

});