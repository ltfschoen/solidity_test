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

* Documentation: http://truffleframework.com/docs

* Solidity
    * Contract (Solidity)
        * Definition - code (functions) and data (state) at address on Ethereum blockchain
