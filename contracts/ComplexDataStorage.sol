pragma solidity ^0.4.0;


contract ComplexDataStorage {
    uint[] x; // Data Location of local variable is "storage"

    function f(uint[] memoryArray) { // Data Location of memoryArray function parameter is "memory"
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