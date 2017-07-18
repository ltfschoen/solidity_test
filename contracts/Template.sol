// Version Pragma
// - Changelog releases with breaking changes 0.x.0, x.0.0
// - Follows npm rules
// - i.e. ^0.4.0
//   - not compile with compiler earlier than 0.4.0
//   - not work on compiler starting from 0.5.0 (breaking changes)
//   - not exact version so bugfix releases possible
pragma solidity ^0.4.11;

// Library
// TODO - Move into separate file
library MyLib
{
    uint public constant symbolName1 = 1;
    uint public constant symbolName2 = 2;

    function MyLib()
    {

    }
}

// Import Statements
// - Similar to JavaScript ES6 (without `default export`)
// - `../` Parent directory, `./` Current directory.
// - Note: Replace `Template` import with a file that is not the current file (current file used as sample only)
import "./Template.sol"; // Global level current scope import of symbols from filename
import * as symbolName1 from "./Template.sol"; // Create new global symbols from filename
import * as symbolName2 from "./Template.sol"; // Parent directory path resolved
import {
symbolName1 as alias, // Create new global symbol `alias` referencing `symbol1`
symbolName2
} from "./Template.sol";

// Compiler Mappings and Command-Line Compiler `solc`
// - Specific path prefex Re-mapping. Fall-back Re-mapping with longest key first
//   - Re-maps "github.com/abc/lib" to "/usr/local/lib" for compiler to read file
//   - Run Command-Line Compiler `solc github.com/abc/lib/=/usr/local/lib/`
//     (i.e. `solc <context>:<prefix>=<target>` after cloning "github.com/abc/lib/" into "/usr/local/lib/"
//   - Replace with a file other than the current file (current file used as sample only)
//   - ISSUE: Below does not work
//import "https://github.com/ltfschoen/solidity_test/tree/master/contracts/Migrations.sol" as example_mapping;

//   - Re-mappings (Remix supported) depend on Context allowing configure different library versions to import
//     - Example: Re-map so that:
//       - Imports in `module1` point to New Version
//       - Imports in `module2` point to Old Version
//         `solc module1:github.com/abc/lib/=/usr/local/lib/ \
//               module2:github.com/abc/lib/=/usr/local/lib_old/ \
//               source.sol
// - Note: `solc` only allows include files from within directory/subdirectory where explicitly
//         specified source file located or re-mapping target
// - Note: `solc` allows direct absolute includes with remapping `=/`

// Comments
// - Single line comments `//`
// - Multi-line comments `/*...*/`
// - NatSpec comments `///` or `/**...*/` (multi-line) shown when user is asked to confirm a transaction
// - Doxygen-style tags:
//
/**
 *  @section SHORT DESCRIPTION
 * <Short one line description>
 *
 * @section LONG DESCRIPTION
 * <Longer description>
 * <Multiple lines or paragraphs>
 *
 * @param  Description of function input parameter
 * @param  ...
 *
 * @return Description of return value
 */

/** @title <enter_contract_title_here>. */
contract Template {

    // Enum - create custom types with finite set of values
    enum State {
        Created,
        Locked,
        Inactive
    }

    // Struct declaration - create custom type definitions to group variables
    struct Voter {
        uint weight;
        bool voted;
        address delegate;
        uint vote;
    }

    // Address - Ethereum address 20 byte value serves as base for contract
    // - Members include:
    //   - `balance` - property to query balance of address
    //   - `transfer` - property to send Ether (Wei units) to address
    address public seller;
    address x = 0x123;
    address myAddress = this;

    // State variables - values permanently stored in contract storage
    uint storedData;

    // Event declaration
    event HighestBidIncreased(address bidder, uint amount);

    // Modifier declaration
    modifier onlySeller() {
        require(msg.sender == seller);
        _;
    }

    /// Modifier implementation
    function abort()
        onlySeller
        returns (bool abortedSuccess)
    {
        return true;
    }

    /// Functions
    /// - Static Typing - Solidity is statically typed language so type of
    ///   each variable (state and local) must be known at compile-time
    function bid()
        payable
        returns (bool highestBidIncreasedSuccess)
    {
        // Event triggering
        HighestBidIncreased(msg.sender, msg.value);

        return true;
    }

    function sendMoney(address sender, uint value)
        internal
        returns (bool success)
    {
        if (x.balance < 10 && myAddress.balance >= 10)
            x.transfer(10);
            return true;
        return false;
    }

    function send()
    {

    }

    /**@dev Function Template smart contract algorithm.
     * @param p1 Parameter 1.
     * @param p2 Parameter 2.
     * @return r1 Calculation 1.
     * @return r2 Calculation 2.
     * Executable unit of code within contract
     */
    function rectangle(uint p1, uint p2)
        returns (uint r1, uint r2)
    {
        r1 = p1 + p2;
        r2 = p1 * p2;
    }

    /// Value Types
    /// - Passed by Value types of variables
    ///   (copied when used as function arguments or for assignments)
    function playWithValueTypes()
    {
        // Value Types
        bool myBool = true || false;

        // Logic
        bool myLogic1 = ((!true || false) && true) == (false || true);

        // Logic - Short-Circuit Rule
        bool myLogicShortCircuit = t() || f();

        // Integers
        int i1 = -1; // Signed integer (alias for `int256`)
        uint ui1 = 1; // Unsigned integer (alias for `uint256`)
        uint8 kw8 = 8; // Unsigned of 8 up to 256 (i.e. `uint256`)

        // Operators
        bool comp = (1 <= 1) == (1 < 2); // Comparisons
        // TODO - Bit operators - http://solidity.readthedocs.io/en/develop/types.html
        // TODO - Arithmetic operators - http://solidity.readthedocs.io/en/develop/types.html
        // - Note: Division truncates unless both operators are literals
        // - Note: Division by zero and modulus zero throws runtime exception
    }

    function t() returns (bool) { return true; }
    function f() returns (bool) { return false; }
}