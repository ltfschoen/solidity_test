pragma solidity ^0.4.4;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SubCurrency.sol";

contract TestSubCurrency {

    function testInitialBalanceUsingDeployedContract() {
        SubCurrency subCurrency = SubCurrency(DeployedAddresses.SubCurrency());

        uint expected = 1000;

        Assert.equal(subCurrency.getBalance(tx.origin), expected, "Owner should have 1000 SubCurrency initially");
    }

    function testInitialBalanceWithNewSubCurrency() {
        SubCurrency subCurrency = new SubCurrency();

        uint expected = 1000;

        Assert.equal(subCurrency.getBalance(tx.origin), expected, "Owner should have 1000 SubCurrency initially");
    }

//    function testTransfersFromAccountValue() {
//        SubCurrency subCurrency = SubCurrency(DeployedAddresses.SubCurrency());
//
//        // https://github.com/ethereum/solidity/issues/1685
//        subCurrency.sendSubCurrency(0x002b5ad5c4795c026514f8317c7a215e218dccd6cf, 100);
//
//        uint expected = 900;
//
//        Assert.equal(subCurrency.getBalance(tx.origin), expected, "It should leave value 900 in sender account.");
//    }

}