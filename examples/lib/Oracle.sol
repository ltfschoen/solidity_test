pragma solidity ^0.4.11;

// Reference: https://solidity.readthedocs.io/en/develop/types.html
contract Oracle {

    struct Request {
        bytes data;
        function(bytes memory) external callback;
    }

    Request[] requests;

    event NewRequest(uint);

    function query(bytes data, function(bytes memory) external callback) {
        requests.push(Request(data, callback));
        NewRequest(requests.length - 1);
    }

    function reply(uint requestID, bytes response) {
        // Check the reply comes from a trusted source
        requests[requestID].callback(response);
    }
}

contract OracleUser {

    Oracle constant oracle = Oracle(0x1234567); // a known contract address

    function buySomething() {
        oracle.query("USD", this.oracleResponse);
    }

    // function oracleResponse(bytes response) {
    // Reference: https://ethereum.stackexchange.com/questions/11246/convert-struct-to-bytes-in-solidity
    function oracleResponse(bytes response) returns (bytes memory) {
        require(msg.sender == address(oracle));
        // Use the data
        uint _size = bytes(response).length;
        bytes memory _data = new bytes(_size);
        return _data;
    }
}