const SimpleStorage = artifacts.require("./SimpleStorage.sol");

contract('SimpleStorage', function(accounts) {

  it("should store the value 100", function() {
    return SimpleStorage.deployed().then(function(instance) {
      // console.log(instance);
      simpleStorageInstance = instance;
      return simpleStorageInstance.set(100, {from: accounts[0]});
    }).then(function() {
      return simpleStorageInstance.get.call();
    }).then(function(storedData) {
      assert.equal(storedData, 100, "The value 100 was not stored.");
    });
  });

});
