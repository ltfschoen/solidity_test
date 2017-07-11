// Reference: https://www.ethereum.org/cli
const SubCurrency = artifacts.require("./SubCurrency.sol");

// Listen for Sent "event" to fire on the blockchain
module.exports = function(callback) {
  resp = undefined;
  SubCurrency.Sent().watch({}, '', function(error, result) {
    if (!error) {
      resp = 1;
      console.log(resp);
      console.log("SubCurrency transfer: " + result.args.amount +
        " coins were sent from " + result.args.from +
        " to " + result.args.to + ".");
      console.log("Balances now:\n" +
        "Sender: " + SubCurrency.balances.call(result.args.from) +
        "Receiver: " + SubCurrency.balances.call(result.args.to));
    }
  })
};

