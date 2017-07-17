pragma solidity ^0.4.11;

// Blind option features:
// - Bids commited by bidder during bidding period are only long crytographic
//   hashes (not actual bids)
//   - Assumed near impossible to find two bid values with equal hashes
// - Reveal bids by bidders at end of bidding period
//   - Bidders send unencrypted values to Contract that checks hash value matches
//     their bid period hash
// - ISSUE - Bidder may not send money after winning auction
//   - OPTION - Force bidder to send money along with initial bid
//     - ISSUE - Blinding of the value transfers is not possible (anyone can see value)
//       - SOLUTION - Only accept bid values higher than the highest bid.
//                    During bidding period add bids less than highest
//                    bid (invalid) to pending refunds.
//                    During revealing phase
//
contract BlindAuction {
    struct Bid {
        bytes32 blindedBid;
        uint deposit;
    }

    address public beneficiary;
    uint public auctionStart;
    uint public biddingEnd;
    uint public revealEnd;
    bool public ended;

    mapping(address => Bid[]) public bids;

    address public highestBidder;
    uint public highestBid;

    mapping(address => uint) pendingReturns;

    event AuctionEnded(address winner, uint highestBid);

    /// Modifiers conveniently validate inputs to functions.
    /// `onlyBefore` is applied to `bid`
    /// New function body is the modifier's body where
    /// `_` is replaced by the old function body.
    modifier onlyBefore(uint _time) { require(now < _time); _; }
    modifier onlyAfter(uint _time) { require(now > _time); _; }

    function BlindAuction(
        uint _biddingTime,
        uint _revealTime,
        address _beneficiary
    ) {
        beneficiary = _beneficiary;
        auctionStart = now;
        biddingEnd = now + _biddingTime;
        revealEnd = biddingEnd + _revealTime;
    }

    /// Blinded bid placed
    /// - `_blindedBid` = keccak256(value, fake, secret).
    /// - `payable` to receive Ether.
    function bid(bytes32 _blindedBid)
        payable
        onlyBefore(biddingEnd)
    {
        bids[msg.sender].push(Bid({
            blindedBid: _blindedBid,
            deposit: msg.value
        }));
    }

    /// Reveal blinded bids.
    /// - Refund senders where blinded bid
    ///   - Valid (not match crytographic hash or fake flag raised)
    ///   - Original bid is greater than value in cryptographic hash
    ///     (avoid fake senders or those that send
    ///   - Not absolute highest bid
    /// - Ether only refunded if bid correctly revealed in revealing phase.
    /// - Valid bid if Ether sent with bid `bid.deposit` is at least
    ///   bid cryptographic hash value and not fake flag raised.
    /// - Same sender address can make multiple deposits
    /// place multiple bids.
    function reveal(
        uint[] _values,
        bool[] _fake,
        bytes32[] _secret
    )
        onlyAfter(biddingEnd)
        onlyBefore(revealEnd)
    {
        uint length = bids[msg.sender].length;
        require(_values.length == length);
        require(_fake.length == length);
        require(_secret.length == length);

        uint refund;
        for (uint i = 0; i < length; i++) {
            var bid = bids[msg.sender][i];
            var (value, fake, secret) = (_values[i], _fake[i], _secret[i]);
            if (bid.blindedBid != keccak256(value, fake, secret)) {
                // Do not refund deposit to bid sender (incorrect) of this iteration
                // Blinded bid failed to match cryptographic hash.
                // Skip to next bid iteration
                continue;
            }
            // Increase refund by original deposit, but then reduce refund by
            // cryptographic hash value when all the following:
            // - If not fake
            // - If original deposit value greater than or equal to iteration hash value
            // - If highest bid (calling placeBid returns true)
            refund += bid.deposit;
            if (!fake && bid.deposit >= value) {
                if (placeBid(msg.sender, value))
                    refund -= value;
            }
            // Prevent sender from reclaiming same deposit
            bid.blindedBid = 0;
        }
        msg.sender.transfer(refund);
    }

    // `internal` function only callable from contract itself (or derived contracts)
    function placeBid(address bidder, uint value) internal
        returns (bool success)
    {
        if (value <= highestBid) {
            return false;
        }
        if (highestBidder != 0) {
            // Refund the previously highest bidder.
            pendingReturns[highestBidder] += highestBid;
        }
        highestBid = value;
        highestBidder = bidder;
        return true;
    }

    /// Withdraw bid that was overbid.
    function withdraw() returns (bool) {
        var amount = pendingReturns[msg.sender];
        if (amount > 0) {
            // Prevent recipient calling function multiple times as part of
            // receiving call by setting `pendingReturns` to zero before `send`
            // returns (i.e. conditions -> effects -> interaction)
            pendingReturns[msg.sender] = 0;

            if (!msg.sender.send(amount)){
                // Reset amount pending to be refunded. Not need to call throw
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    /// End auction. Send highest bid to beneficiary.
    function auctionEnd()
        onlyAfter(revealEnd)
    {
        require(!ended);
        AuctionEnded(highestBidder, highestBid);
        ended = true;
        // Send all money since some refunds might have failed

        // `this.balance` where `this` is pointer to current contract instance of type
        // BlindAuction derived from Address
        beneficiary.transfer(this.balance);
    }
}