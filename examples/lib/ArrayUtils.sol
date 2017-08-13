pragma solidity ^0.4.11;

//// Reference: https://solidity.readthedocs.io/en/develop/types.html
//library ArrayUtils {
//    /*
//     * Internal function types can be used in internal library functions
//     * since they will be part of same code context
//     */
//    function map(
//        uint[] memory self,
//        function (uint) returns (uint) f
//    )
//        internal
//        returns (uint[] memory r)
//    {
//        r = new uint[](self.length);
//        for (uint i = 0; i < self.length; i++) {
//            r[i] = f(self[i]);
//        }
//    }
//
//    function reduce(
//        uint[] memory self,
//        function (uint, uint) returns (uint) f
//    )
//        internal
//        returns (uint r)
//    {
//        r = self[0];
//        for (uint i = 1; i < self.length; i++) {
//            r = f(r, self[i]);
//        }
//    }
//
//    function range(
//        uint length
//    )
//        internal
//        returns (uint[] memory r)
//    {
//        r = new uint[](length);
//        for (uint i = 0; i < r.length; i++) {
//            r[i] = i;
//        }
//    }
//}
//
//contract Pyramid {
//
//    using ArrayUtils for *;
//
//    function pyramid(uint l) returns (uint) {
//        return ArrayUtils.range(l).map(square).reduce(sum);
//    }
//
//    // Square of one given argument
//    function square(uint x) internal returns (uint) {
//        return x * x;
//    }
//
//    // Addition of two given arguments
//    function sum(uint x, uint y) internal returns (uint) {
//        return x + y;
//    }
//}