* Setup
    * Truffle Scaffold `truffle init`
    * Step 1: Node switch and dependencies `nvm install; npm install; truffle install;`
  	* Step 2: Run Ethereum Client (in separate Terminal tab)
  		* [ethereumjs-testrpc](https://github.com/ethereumjs/testrpc)
  			* Note:
  				* 1 Wei == 	1000000000000000000 Ether
  			* Run Bash Script `bash testrpc.sh`
  			    * Deletes/create DB folder for Ethereum test blockchain
  			    * Loads Ethereum TestRPC Server and stores in DB folder.
  			    * Creates Account #1 with ~1337 Ether, and Account #2 with ~2674 Ether.
  			    * Unlocks each Account
			* Server on http://localhost:8545
			* Check Network ID of TestRPC Server
			    * `curl -X POST --data '{"jsonrpc":"2.0","method":"net_version","params":[]}' http://localhost:8545`
    * Step 3: Compile, Migrate: `truffle compile --compile-all; truffle migrate --reset --network development;`
    * Step 4: Tests: `truffle test` or `npm run test`
        * **IMPORTANT** - Ensure already launched TestRPC by running previous steps

* Debugging
    * Remix IDE Documentation - https://remix.readthedocs.io/en/latest/
        * Remixd to access shared folder on local machine in Remix IDE - https://remix.readthedocs.io/en/latest/tutorial_remixd_filesystem.html
        * Debugging Dapp using Remix, Geth, Mix - https://remix.readthedocs.io/en/latest/tutorial_mist.html
    * Remix IDE - https://remix.ethereum.org/
        * Debug Tutorial https://remix.readthedocs.io/en/latest/tutorial_debug.html
            * Copy/paste .sol contract
            * Click Contract > Environment > JavaScript VM
            * Click Create
            * Enter parameter values to pass to Contract methods and Run them (i.e. `set` value 10)
            * Click Debugger
                * Enter Block number (i.e. 10)
                * Add Breakpoints
                * Click Left/Right arrow to step through Transaction and inspect EVM property values

* Documentation: http://truffleframework.com/docs

* Solidity
    * Definitions
        * Contract (Solidity) - code (functions) and data (state) at address on Ethereum blockchain

* Blockchain
    * Definitions
        * Blockchain -
            * Globally shared Transactional Database where all network participants may read entries
        * Ethereum Virtual Machine (EVM) -
            * Runtime environment - Sandboxed and completely isolated runtime environment for smart contracts in Ethereum,
            where code running inside EVM has no access to network, filesystem or other processes.
            * Mining
                * Order selection mechanism to adding blocks to blockchain. Reverted blocks occur only at tip of the chain.
            * Transaction -
                * Request prior to change state in database that must be accepted by others
                * No other transactions may alter transaction whilst being applied
                * Transaction cryptographically signed by sender (creator) to guard access to database modifications
                (i.e. only user with key to account may transfer electronic currency from it)
                * Transaction is message sent from one account to another (the same, or a special **Zero-account**) containing
                **Payload (binary data)** and **Ether**. The Payload is used as Input to any code contained at the
                Recipient target account.
                * Transactions sent to **Zero-account** (with address `0`) creates a **New Contract** whose address
                is derived from the Nonce. The Payload of the Transaction that creates the New Contract is taken
                to be the EVM bytecode, and then the output of execution is permanently Stored as the Code of the Contract.
                The code sent to create the New Contract is code that generates/returns the Contract Code, not the actual
                Contract Code itself.
            * Gas
                * Transactions when created by Sender Account are charged Gas at a Gas Price (set the by creator of the Transaction)
                that must be paid upfront at `gas_price * gas` to limit the amount of work required. Gas
                is gradually depleted according to specific rules to pay for the EVM to execute the Transaction.
                * Gas that was charged by not used by end of execution is Refunded.
                * Out-of-gas exception is triggered that reverts all modifications to the state in current call frame
                if all Gas is used up prior to end of execution.
            * Block -
                * Blocks form linear sequence in time as they are added to the blockchain at regular intervals
                  (every ~17 seconds in Ethereum)
                * Order of Transactions is selected
                * Transactions bundled into a "block" prior to execution and distribution amongst participating nodes
                * Contradicting Transaction situations cause second transaction to be rejected and not added to "block"
                * Double-spend Attack - two transactions exist in network that both want to empty an account (not an issue due to block ordering)
            * Accounts (share same address space)
                * External Accounts - controlled by public-private key pairs (humans) that determine the address
                * Contract Accounts - controlled by code stored alongside External Accounts and address determined at time contract created
                  derived from the Nonce
            * Account Storage
                * **Storage** is an accounts persistent memory key-value store that maps 256-bit words to 256-bit words.
                * Storage cannot be enumerated from within a Contract
                * Contract read/write to Storage is costly
                * Contracts cannot read/write to another Account Storage
            * Account Memory
                * Contracts obtain fresh instance of Memory for each Message Call
                * Memory is linear and addressed at byte level
                * Memory reads limited to 256-bit widths
                * Memory writes limited to either 8-bits or 256-bit widths
                * Memory expands (by a 256-bit word) when accessing (read/write) a previously
                untouched memory word (offset within a word) and Gas cost must be paid at time of expansion
                * Memory costs more as it scales quadratically
            * Account Balance
                * Each account has a balance in Ether (a factor of Wei) modifiable by sending transactions in Ether
            * Account Nonce - transaction counter in each account that determines address of Contract Accounts
            * Nonce - address derived for New Contract based on the sender and the number of transactions they have sent
            * Computations - Computations on the EVM are performed on a **Stack** (Stack Machine) having
            max size of 1024 elements with 256-bit words.
                * Stack Access - only from Top of stack by either
                    * Copying one of the top 16 elements to the top OR
                    * Swap top element with one of other top 16 elements
                    * Not possible to just access deeper elements in stack without first removing top of stack
                * Stack Operations - depending on the operation
                    * Pop top one or more elements from stack and Push result onto stack
                    * Move stack elements to Storage or Memory
            * Instruction Set -
                * Instruction Set is minimal to avoid incorrect implementations and Consensus problems
                * Instructions operate on 256-bit words (basic data type)
                * Operations Available - Arithmetic, Bit, Logic, Comparison, Conditional/Unconditional Jumps
                * Contracts may access relevant properties of current Block (i.e. Block Number, Timestamp)
            * Message Calls
                * Message Calls are similar to Transactions (having Source, Target, Payload Data, Ether, Gas, Return Data)
                * Contracts may call other Contracts
                * Contracts may send Ether to Non-Contract Accounts using Message Calls
                * Transactons consist of Top-Level Message Call that may create more Message Calls
                * Contract determines quantity of remaining Gas to send to Lower-Level/Inner Message Calls and how much to retain
                    * Exceptions (i.e. Out-of-gas) occurring in Lower-Level/Inner Message Calls are signalled with error
                    value placed on the Call Stack, and only the Gas sent with the Call is used up. Calling Contract in Solidity
                    causes manual exception so exceptions "bubble up" the Call Stack
                * Called Contract (may be same as Caller Contract) receives clean instance of Memory with
                access to Message Call Payload from the Caller Contract (provided in separate **Calldata** area).
                Called Contract returns data to locatoin preallocated in Callers Memory.
                * Calls limited to 1024-bit depth, so Loops preferred over Recursive calls for complex operations.
            * Delegatecall / Callcode and Libraries
                * Delegatecall - same as Message Call but executes code at target address in context of Calling Contract
                 and no change occurs in values `msg.sender` and `msg.value` so Calling Contract may dynamically load
                 code from a different address at runtime.
                 Calling Contract uses its own Storage, current address, and balance, but takes code from Called address,
                 allowing implementation of reusable "library" code feature of Solidity that may be applied to
                 a Calling Contracts Storage to implement a complex data structure
            * Logs
                * Logs feature of Solidity allows imlementation of **Events**
                * **Light Clients** (network peers that do not download the whole blockchain) can search and find Logs Data
                in efficient and cryptographically secure way since some part is stored in [Bloom Filters](https://en.wikipedia.org/wiki/Bloom_filter)
                (that check possibility of element being in a set)
                * Contracts can not access Log Data after its created
                * Log Data may be efficiently accessed from outside the blockchain since data may be stored in
                specially indexed data structure that maps all the way up to block level.
            * Create (Contract) Calls
                * Contracts can create other Contracts using special opcode (not just calling zero-address)
                * Create (Contract) Calls differ from Message Calls since Payload Data is executed, result is stored
                as code, and Caller (creator) receives address of New Contract on the Stack
            * Destroy Contract
                * Removal of blockchain code occurs when Contract at address performs `selfdestruct` operation
                (or via `delegatecall` or `callcode`) where remaining Ether stored at address is sent to
                designated target and then Storage and Code removed from state.
                * Archive Nodes - may keep contract storage indefinitely
                * Ethereum Clients - may prune old contracts
                * External Accounts cannot be removed currently from state


* Other
    * Definitions
        * [Cryptographic hash function (aka hashing)](https://en.wikipedia.org/wiki/Cryptographic_hash_function)
        * [Elliptic curve cryptography (ECC)](https://en.wikipedia.org/wiki/Elliptic_curve_cryptography)

* Forums
    * https://forum.ethereum.org/

* TODO
    * http://solidity.readthedocs.io/en/develop/solidity-by-example.html#blind-auction
    * https://truffle-box.github.io/
    * https://github.com/trufflesuite/truffle-contract/blob/master/dist/truffle-contract.js
    * https://github.com/trufflesuite/truffle-artifactor/blob/master/test/contracts.js
    * https://github.com/Sergeon/ethereum-cashbox