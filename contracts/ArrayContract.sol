pragma solidity ^0.4.0;

contract ArrayContract {
    uint[2**20] m_aLotOfIntegers; // Data Location of fixed size local variable is "storage"

    // Dynamic array of pairs (fixed size arrays of length two)
    bool[2][] m_pairsOfFlags;

    // newPairs is stored in "memory" (default for function arguments)
    function setAllFlagPairs(bool[2][] newPairs) {
        // Assignment to "storage" array replaces complete array
        m_pairsOfFlags = newPairs;
    }

    function setFlagPair(uint index, bool flagA, bool flagB) {
        // Access to non-existent index throws an exception
        m_pairsOfFlags[index][0] = flagA;
        m_pairsOfFlags[index][1] = flagB;
    }

    function changeFlagArraySize(uint newSize) {
        // Removed array elements cleared if new size is smaller
        m_pairsOfFlags.length = newSize;
    }

    /// Clear arrays completely identical effect here
    function clear() {
        // Option 1
        delete m_pairsOfFlags;
        delete m_aLotOfIntegers;
        // Option 2
        m_pairsOfFlags.length = 0;
    }

    bytes m_byteData;

    function byteArrays(bytes data) {
        // "bytes" (byte array) stored without padding are treated identical to "uint8[]"
        m_byteData = data;
        m_byteData.length += 7;
        m_byteData[3] = 8;
        delete m_byteData[2];
    }

    function addFlag(bool[2] flag) returns (uint) {
        return m_pairsOfFlags.push(flag);
    }

    /// Create and return a dynamic array `bytes` in "memory"
    function createMemoryArray(uint size) returns (bytes) {
        // Dynamic memory arrays are created using `new`:
        uint[2][] memory arrayOfPairs = new uint[2][](size);

        bytes memory b = new bytes(200);
        for (uint i = 0; i < b.length; i++)
        b[i] = byte(i);
        return b;
    }
}