// Version Pragma
// - Changelog releases with breaking changes 0.x.0, x.0.0
// - Follows npm rules
// - i.e. ^0.4.0
//   - not compile with compiler earlier than 0.4.0
//   - not work on compiler starting from 0.5.0 (breaking changes)
//   - not exact version so bugfix releases possible
pragma solidity ^0.4.11;

// Move into separate file
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
    /**@dev Template smart contract algorithm.
     * @param p1 Parameter 1.
     * @param p2 Parameter 2.
     * @return r1 Calculation 1.
     * @return r2 Calculation 2.
     */
    function rectangle(uint p1, uint p2) returns (uint r1, uint r2) {
        r1 = p1 + p2;
        r2 = p1 * p2;
    }
}