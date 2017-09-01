pragma solidity ^0.4.11;

contract DeleteBalances {
    uint balance;
    uint[] balancesArray;

    function f() {
        uint x = balance;
        delete x; // Sets x to 0, does not affect balance
        delete balance; // Sets balance to 0. No effect on x that still holds a copy
        uint[] y = balancesArray;
        // Note:
        //   - uint[] is a complex object
        //   - y is effected by `delete balancesArray` since `y` is an alias to the `balancesArray` object in "storage"
        //   - `delete y` is not valid since it assigns to local variables
        //   - References to "storage" objects may only be made from existing "storage" objects
        delete balancesArray; // Sets balancesArray.length to zero
    }
}