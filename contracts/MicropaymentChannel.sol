pragma solidity ^0.4.11;

// Micropayment Channel
// - Payment restrict to only sender or recipient
// - Reference: https://github.com/mattdf/payment-channel
contract MicropaymentChannel {

    address public channelSender;
    address public channelRecipient;
    uint public startDate;
    uint public channelTimeout;
    mapping (bytes32 => address) signatures;

    function MicropaymentChannel(address to, uint timeout) payable {
        channelRecipient = to;
        channelSender = msg.sender;
        startDate = now;
        channelTimeout = timeout;
    }

    function CloseChannel(bytes32 h, uint8 v, bytes32 r, bytes32 s, uint value){

        address signer;
        bytes32 proof;

        // ECRecover to check signature by returning address associated with the recovered public key
        // (SHA3/keccak hash) from elliptic curve signature. Returns zero on error.
        // All transactions must be signed.
        // Verify signature by checking returned address associated with recovered public key
        // equals the address (transaction sender) whose private key supposedly signed the hash
        // that created an Elliptic Curve Digital Signature Algorithm (ECDSA) signature,
        // where signature comprises two elliptic curve points
        // `r`, `s`, and `v` (additional 2 bits). Arguments include:
        // - `h` "data" Hash
        // - `r` "signature" Hex values (0-65) of signature (i.e. `0x..`)
        // - `s` "signature" Hex values (66-129) of signature (i.e. `0x` + `..`)
        // - `v` "public key" Hex values (130-131) of signature (i.e. `0x` + `..`)
        // Obtain signer from signature for verification that matches only sender or recipient
        signer = ecrecover(h, v, r, s);

        // Signature is invalid so throw
        if (signer != channelSender && signer != channelRecipient) throw;

        proof = sha3(this, value);

        // Signature valid but not match data provided
        if (proof != h) throw;

        if (signatures[proof] == 0)
            signatures[proof] = signer;
        else if (signatures[proof] != signer){
            // Channel completed and both signatures provided
            if (!channelRecipient.send(value)) throw;
            selfdestruct(channelSender);
        }

    }

    function ChannelTimeout(){
        if (startDate + channelTimeout > now)
            throw;

        selfdestruct(channelSender);
    }

}