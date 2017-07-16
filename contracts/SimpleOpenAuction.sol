pragma solidity ^0.4.11;

// Open auction where everyone can see bids made
contract SimpleOpenAuction {
    address public beneficiary;

    // Times are absolute unix timestamps (seconds since 1970-01-01) or time in seconds.
    uint public auctionStart;
    uint public biddingTime;

    // Current state of the auction.
    address public highestBidder;
    uint public highestBid;

    // Map bidders with their bids. Allows withdrawals of previous bids
    mapping(address => uint) pendingReturns;

    // Set to true at auction end to disallow further change
    bool ended;

    // Events that will be fired on changes
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    // "natspec" comments recognisable by three slashes shown when user asked confirm transaction

    /// Create simple auction with `_biddingTime` seconds bidding
    /// time on behalf of beneficiary address `_beneficiary`.
    function SimpleOpenAuction(uint _biddingTime, address _beneficiary) {
        beneficiary = _beneficiary;
        auctionStart = now;
        biddingTime = _biddingTime;
    }

    /// Bid on auction with value sent together with this transaction.
    /// The value only refunded if auction not won.
    function bid() payable {
        // No arguments are necessary, All info already part of transaction.
        // Keyword "payable" is required for function to receive Ether

        // Revert call if bidding period over
        require(now <= (auctionStart + biddingTime));

        // Reimburse money if new bid not higher than highest bid
        require(msg.value > highestBid);

        // Increase pending returns of previously highest bidder since their bid was beaten by `msg.value`
        if (highestBidder != 0) {
            // Security Risk: Do not send back money simply using `highestBidder.send(highestBid)`
            // as caller may reject it (i.e. by raising call stack to 1023).
            // Safer Option: Recipients should withdraw money reimbursed to them by themselves from `pendingReturns`.
            pendingReturns[highestBidder] += highestBid;
        }

        // Update records with new highest bidder
        highestBidder = msg.sender;
        highestBid = msg.value;

        // Event fired since highest bid increased
        HighestBidIncreased(msg.sender, msg.value);
    }

    /// Withdraw a bid from an address that was beaten by another bid (overbid)
    function withdraw() returns (bool) {
        var amount = pendingReturns[msg.sender];
        if (amount > 0) {
            // Important: Set this to zero since recipient can call this function
            // again (double dipping) during receiving call before `send` returns.
            pendingReturns[msg.sender] = 0;

            // Reset amount owing by restoring money to pending returns if reimbursement failed
            if (!msg.sender.send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    /// End auction and send highest bid to the beneficiary
    function auctionEnd() {
        // Guideline to structuring functions that interact with other contracts
        // (i.e. they call functions or send Ether) into three phases:
        //
        // 1. Conditions - Checking conditions
        // 2. Effects - Performing actions (potentially changing conditions)
        // 3. Interact with other contracts
        //
        // If these phases are mixed up, other contract could call back into
        // current contract and modify the state or cause effects (Ether payout)
        // to be performed multiple times.
        //
        // If functions called internally include
        // interaction with external contracts, they must be considered an interaction with
        // external contracts.

        // 1. Conditions - (i.e. auction not yet ended, not previously called auction ended)
        require(now >= (auctionStart + biddingTime));
        require(!ended);

        // 2. Effects - (i.e. update state that auction ended with highest bidder/bid)
        ended = true;
        AuctionEnded(highestBidder, highestBid);

        // 3. Interaction
        beneficiary.transfer(highestBid);
    }
}