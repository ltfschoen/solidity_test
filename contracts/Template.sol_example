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

import "./lib/ArrayUtils.sol";

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

    enum ActionChoices {
        VoteLeft,
        VoteRight,
        NoVote
    }

    ActionChoices choice;
    ActionChoices constant defaultChoice = ActionChoices.NoVote;

    function setNoVote() {
        choice = ActionChoices.NoVote;
    }

    // Enum types not part of ABI, so signature of "getChoice"
    // automatically changes to "getChoice() returns (uint8)"
    // for all matters external to Solidity. Integer type used will be just
    // large enough to hold all enum values, i.e. if we use larger values,
    // `uint16` will be used instead of `uint8` and so on.
    function getChoice() returns (ActionChoices) {
        return choice;
    }

    function getDefaultChoice() returns (uint) {
        return uint(defaultChoice);
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
    address myAddress = this;
    address contractAddress = 0x123;

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

    /*
     * Declaring External Function Types
     * - Internal `internal` functions usage inside current contract context (code unit) only.
     *   Default is that function types are `internal` so the keyword may be omited.
     *   - Example: lib/ArrayUtils.sol
     * - External functions have an address and function signature and may be passed
     *   via and returned from external function calls.
     *   - Example: lib/Oracle.sol
     *
     * Calling Function Types
     * - Internal Solidity Context
     *   - Call for Internal form public functions of current contract with `f`
     *   - Call for External form public functions of current contract with `this.f`
     * - External Solidity Context
     *   - Treated as `function` type that encodes: address, function identifier, and single `bytes24` type
     *
     * - Reference: https://solidity.readthedocs.io/en/develop/types.html
     */
    function sendMoney(address sender, uint value)
        internal
        returns (bool success)
    {
        // Transfer money from `myAddress` to `contractAddress`
        // - Note: All contracts inherit address members.
        //   Query current contract balance with `this.balance`.
        // - `<address>.balance` queries balance of address
        // - `<address>.transfer` transfers Ether (Wei) to address
        //   - Calls fallback function if recipient is contract address.
        //     Transfer of Ether reverted and exception raised by
        //     current contract (sender) if execution runs out of Gas or fails.
        // - `<address>.send` returns false but not trigger exception upon failure.
        //   - Danger:
        //      - Fails transfer if call stack depth 1024 (forcible by caller)
        //      - Fails if recipient runs out of Gas
        // - Best Practice:
        //   - Safely transfer Ether by always checking `send` return value is true
        //     or use `transfer` instead. Alternatively use pattern where
        //     recipient withdraws money instead of it being sent to them.
        //   - Danger: Unknown contracts may be malicious when called. Beware of
        //     control being handed over allowing subsequent calls into current contract
        //     that may change state variables.
        // Advanced:
        // - Note: Use following Low-Level functions as last resort since break Solidity type-safety.
        //   - `<address>.gas() option available
        // - `<address>.call` used to interface with contract addresses that
        //   do not adhere to Application Binary Interface (ABI).
        //   `call` takes arguments that are padded to 32 bytes and concatenated
        //   (except when first argument encoded to 4 bytes to allow use function signatures)
        //   `call` returns:
        //      - true - if invoked function terminated
        //      - false - if EVM exception raised
        //   `call` does not allow accessing actual data returned
        // - `<address>.delegateCall` differs from `call` since only code
        //   (i.e. fallback function) of given address is used, but take from
        //   current `msg.sender` contract other information (balance, storage, etc).
        //   `delegateCall` uses Library code stored in other contract.
        //   `delegateCall` requires ensure storage layout of both current
        //   `msg.sender` and other contract is suitable for usage of `deletageCall`.
        //   `<address>.value() option NOT supported for `delegateCall`.

        // TODO - understand purpose of `call`
        contractAddress.call("register", "MyName");
        contractAddress.call(bytes4(keccak256("fun(uint256)")), a);

        if (contractAddress.balance < 10 && myAddress.balance >= 10)
            contractAddress.transfer(10);
            return true;
        return false;
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

        // Byte Arrays (Fixed-size)
        // - Contracts cannot read strings returned by another contract
        // - EVM has word-size of 32 bytes (optimised to deal with data in chunks of 32 bytes)
        // - Solidity compiler generates more bytecode and does more work with high Gas cost
        //   when data is not in 32 byte chunks that fit in the EVMs word-size.
        // - Strings are in `bytes` and are dynamically sized type
        // - `<bytes32_array>.length` returns fixed length of byte array
        bytes mystring = "dsa";
        bytes32 mybytes = bytes32(mystring);

        // Byte Arrays (Dynamically-sized)
        // - `bytes` - use for dynamically-sized raw byte data array
        // - `string` dynamically-sized UTF-8-encoded string
        // - Note: Always bytes1 to bytes32 since much cheaper Gas-wise.

        // Inline Assembly
        // - `mload` reads memory into a register
        // - `mstore` writes memory into a register
        // - String or `bytes` have first 256 bit for length of data
        // - `bytes32` is fixed
        // - Note: Comparing strings stored in a contract with strings from another
        //   contract is difficult since cannot pass strings between them. Solution is
        //   to convert strings to `bytes32` and then change some
        //   characters within these strings (or bytes32) as a result of the comparisons
        //   by using mload from `mystring` with a 32 byte offset and then using
        //   `mstore` to write directly to `mybytes`.
        //   Reference: https://gist.github.com/axic/ce82bdd1763c04ef8138c2b905985dab

    }

    function t() returns (bool) { return true; }
    function f() returns (bool) { return false; }
}