* Setup
    * Truffle Scaffold `truffle init`
    * Node switch and dependencies `nvm install; npm install; truffle install;`
  	* Run Ethereum Client (in separate Terminal tab)
  		* [ethereumjs-testrpc](https://github.com/ethereumjs/testrpc)
  			* Note:
  				* 1 Wei == 	1000000000000000000 Ether
  			* Run Bash Script `bash testrpc.sh` to Delete/Create DB folder for Ethereum test blockchain. Load TestRPC Server. Create Account #1 with 1337 Ether, and Account #2 with 2674 Ether. Unlock each Account
			* Served on http://localhost:8545
    * Documentation: http://truffleframework.com/docs
    * Commands:
        * Compile, Migrate, Test: `truffle compile --compile-all; truffle migrate --reset --network development`

* Solidity
    * Contract (Solidity)
        * Definition - code (functions) and data (state) at address on Ethereum blockchain
