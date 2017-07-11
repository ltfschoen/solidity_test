pragma solidity ^0.4.4;

/*
 *  About: Contract that implements simplest form of Cryptocurrency that generates
 *    coins out of thin air. Issuance scheme prevents generation of coins by anyone
 *    other than creator of the Contract. Anyone may send coins to each other without
 *    username and password registration, only Ethereum keypair is required.
 *
 *  Functionality:
 *    - Declare publicly accessible state variable of type address
 *      that is 160 bit value that prevents arithmetic operations but suitable
 *      for storing Contract addresses or keypairs belonging to external people.
 *    - Query balance of single account by create publicly accessible state value
 *      of complex datatype that maps addresses to unsigned integers using Hash Tables
 *      that are virtually initialised so all possible keys exist and are mapped to a value with
 *      byte-representation of all zeros.
 */
contract SubCurrency {
    // Keyword `public` generates function that allows state variable value
    // readable from outside by other Contracts of form:
    //   `function minter() returns (address) { return minter; }`
    address public minter;

    // Keyword `public` generates getter function is of form:
    //   `function balances(address _account) returns (uint) { return balances[_account]; }`
    mapping (address => uint) public balances;

    // Declare "event" called 'SentSubCurrency' that is fired in `send` function.
    // User interfaces and servers may listen for the "event" to fire
    // on the blockchain with minimal cost.
    // Listener receives arguments `from`, `to`, `amount` when "event" fired
    // to help track transactions
    event SentSubCurrency(address from, address to, uint amount);

    // Constructor run only when contract created
    function SubCurrency() {
        minter = msg.sender;
        balances[tx.origin] = 1000; // Initial balance of account[0]
    }

    function sendSubCurrency(address receiver, uint amount) returns (bool success) {
        if (balances[msg.sender] < amount) {
            return false;
        }
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        SentSubCurrency(msg.sender, receiver, amount);
        return true;
    }

    function getBalance (address user) constant returns (uint balance) {
        return balances[user];
    }

    // Fallback Function
    function() {}
}