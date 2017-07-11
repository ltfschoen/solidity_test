#!/bin/bash
# File: ~/launch.sh

# By Luke Schoen in 2017 to load new tab and run TestRPC server

function new_tab() {
  TAB_NAME=$1
  DELAY=$2
  COMMAND=$3
  osascript \
    -e "tell application \"Terminal\"" \
    -e "tell application \"System Events\" to keystroke \"t\" using {command down}" \
    -e "do script \"$DELAY; printf '\\\e]1;$TAB_NAME\\\a'; $COMMAND\" in front window" \
    -e "end tell" > /dev/null
}

rm -rf ./db
mkdir db && mkdir db/chaindb

# Create new tab to load the server and show logs.
new_tab "Ethereum TestRPC Tab" \
        "echo 'Loading TestRPC...'" \
        "cd ~/code/blockchain/solidity_test; testrpc --account='0x0000000000000000000000000000000000000000000000000000000000000001, 10002471238800000000000' \
                  --account='0x0000000000000000000000000000000000000000000000000000000000000002, 10004471238800000000000' \
                  --unlock '0x0000000000000000000000000000000000000000000000000000000000000001' \
                  --unlock '0x0000000000000000000000000000000000000000000000000000000000000002' \
                  --blocktime 0 \
                  --deterministic true \
                  --port 8545 \
                  --hostname localhost \
                  --gasPrice 20000000000 \
                  --gasLimit 0x47E7C4 \
                  --debug true \
                  --mem true \
                  --db './db/chaindb'"
