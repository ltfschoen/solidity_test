pragma solidity ^0.4.11;

contract SafeRemotePurchase {
    uint public value;
    address public seller;
    address public buyer;
    enum State { Created, Locked, Inactive }
    State public state;

    // Solidity only allows integer arithmetic with even payments.
    // - Odd number divided by 2 truncates the decimal then re-multiplying by 2
    //   does not give back same number
    function SafeRemotePurchase() payable {
        seller = msg.sender;
        value = msg.value / 2;
        require((2 * value) == msg.value);
    }

    // Modifiers
    modifier condition(bool _condition) { require(_condition); _; }
    modifier onlyBuyer() { require(msg.sender == buyer); _; }
    modifier onlySeller() { require(msg.sender == seller); _; }
    modifier inState(State _state) { require(state == _state); _; }

    // Events
    event Aborted();
    event PurchaseConfirmed();
    event ItemReceived();

    /// Abort purchase and reclaim Ether only callable by seller before contract locked.
    function abort()
        onlySeller
        inState(State.Created)
    {
        Aborted();
        state = State.Inactive;
        seller.transfer(this.balance);
    }

    /// Confirm purchase as buyer.
    /// Transaction must include `2 * value` Ether (i.e. allow for Gas fee)
    /// Ether locked until `confirmReceived` called.
    function confirmPurchase()
        inState(State.Created)
        condition(msg.value == (2 * value))
        payable
    {
        PurchaseConfirmed();
        buyer = msg.sender;
        state = State.Locked;
    }

    /// Confirm buyer received item to release locked Ether.
    function confirmReceived()
        onlyBuyer
        inState(State.Locked)
    {
        ItemReceived();
        // Change state first otherwise contract may be called and trigger
        // `transfer` multiple times.
        state = State.Inactive;

        // Allows both buyer and seller to block refund. Use "Withdraw pattern".
        buyer.transfer(value);
        seller.transfer(this.balance);
    }
}