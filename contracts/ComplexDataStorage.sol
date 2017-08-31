pragma solidity ^0.4.0;


contract ComplexDataStorage {
    uint[] x; // Data Location of local variable is "storage"

    function e(uint len) {
        // Allocate Memory Array of variable length not resizable
        // - Length a.length == 7
        // - Length b.length == len
        uint[] memory a = new uint[](7);
        bytes memory b = new bytes(len);
        a[6] = 8; // Modify last element of a
        f([uint(1), 2, 3, 4, 5, 6, 7, 8]); // Array Literal / Inline Array in "memory"

        // Type error since uint[3] fixed size "memory" cannot be converted to dynamic-sized uint[] "memory" arrays
        // uint[] x = [uint(1), 3, 4];
    }

    function f(uint[8] memoryArray) { // Data Location of memoryArray function parameter is "memory"
        x = memoryArray; // Copy array to "storage"
        var y = x; // Assign pointer to "storage"
        y[7];
        y.length = 2; // Mutate x through y
        delete x; // Clears array x upon which y is dependent
        // Does not work since need to create a new temporary unnamed array in "storage"
        // but storage is "statically" allocated:
        // y = memoryArray;

        // Does not work, since it "reset" pointer without sensible location to point to
        // delete y;
        g(x); // Calls g, handing over a reference to x
        h(x); // Calls h and creates an independent, temporary copy of x in "memory"
    }

    function g(uint[] storage storageArray) internal {}
    function h(uint[] memoryArray) {} // Data Location of memoryArray function parameter is "memory"
}