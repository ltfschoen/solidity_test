pragma solidity ^0.4.11;

// @title Voting with delegation
contract Ballot {

    // Declare to represent Single Voter
    struct Voter {
        uint weight; // weight accumulated by delegation
        bool voted;  // whether person already voted
        address delegate; // person delegated to (Delegatee)
        uint vote;   // index of voted proposal
    }

    // Declare to represent Single Proposal.
    struct Proposal {
        bytes32 name;   // short name (up to 32 bytes)
        uint voteCount; // number of votes accumulated
    }

    address public chairperson;

    bytes32 public value;

    address[] votersCollection;

    bool public initiated;

    // Declare state variable to store `Voter` struct for each possible address.

    // Iterate mapping: https://forum.ethereum.org/discussion/1995/iterating-mapping-types
    mapping(address => Voter) public voters;

    // Dynamically-sized array of `Proposal` structs.
    Proposal[] public proposals;

    /// Constructor creates new Ballot to with:
    ///  - chairperson (originator) granted voting authority by changing `weight` to `1`
    ///  - proposals (comprising list of proposalNames/candidates) each with voteCount
    function Ballot(bytes32[] proposalNames) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        // Iterate `proposalNames`, create New `Proposal` Object, append to `proposals` array
        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }

        votersCollection.push(chairperson);

        initiated = true;
    }

    /// Grant Voter authority to vote on Ballot through call only from chairperson
    ///  - Grants Voter authority by changing `weight` to `1`
    ///  - Revert all changes to state and Ether balances if `require` evaluates to `false`
    ///  - WARNING: Currently `require` consumes all provided Gas
    function giveRightToVote(address voter) {
        // `require` - http://solidity.readthedocs.io/en/develop/control-structures.html
        require((msg.sender == chairperson) && !voters[voter].voted && (voters[voter].weight == 0));
        // if (msg.sender != chairperson || voters[voter].voted) {
        //   // `throw` terminates and reverts all changes to state and Ether balances but consume all provided Gas
        //   throw;
        // }
        voters[voter].weight = 1;

        votersCollection.push(voter);
    }

    /// Delegate Vote to voter with `to` address
    ///  - Delegator `sender` (reference) must not have previously voted
    ///  - Delegator must not delegate to themself (self-delegation)
    function delegate(address to) {
        // Pass by reference `voters[msg.sender]` to `sender`
        Voter sender = voters[msg.sender];

        require(!sender.voted);
        require(to != msg.sender);

        // if (sender.voted)
        //   throw;

        // if (to == msg.sender) {
        //   throw;
        // }

        // // WARNING: Loops are dangerous since they may cause the Contract
        // //   to get stuck or if they run too long more Gas than is available
        // //   in the block may be required resulting in delegation being aborted.
        // while (voters[to].delegate != address(0)) {
        //    to = voters[to].delegate;
        //    require(to != msg.sender);
        //}

        // - Forward the delegation by changing the delegate voter address `to`
        //   to the sub-delegate only if the proposed delegate voter address (`to`)
        //   already has an address set to its `delegate` property
        //   (sub-delegate) and only if the sub-delegate address does not match
        //   the `sender` address (avoids self-delegation through proposed delegate)
        if (voters[to].delegate != address(0)) {
            to = voters[to].delegate;
            require(to != msg.sender);
        }

        // Delegator `sender` updated with:
        // - `voted` property set `true` since defers vote to `delegate`
        // - `delegate` property set to `to` address
        //
        // Delegatee `to` address passed by reference to `delegate` (of Voter type) then
        // - If `delegate` has already voted then add `voteCount` of the `Proposal` in list
        //   of `proposals` with the `weight` (extent of voting influence) value of the Delegator
        // - Else if `delegate` has not voted yet then assign the Delegator `sender` voting `weight`
        //   to the `delegate` for use when they proceed to vote on behalf of the Delegator
        //   (the Delegatee may have a large `weight` if multiple Delegators deferred their `weight` to
        //   allowing them to vote multiple times)

        // Modify `voters[msg.sender].voted` since `sender` passed by reference
        sender.voted = true;
        sender.delegate = to;
        Voter delegate = voters[to];
        if (delegate.voted) {
            proposals[delegate.vote].voteCount += sender.weight;
        } else {
            delegate.weight += sender.weight;
        }
    }

    /// - Vote by a `Voter` from their `weight` (amount of times they may
    ///   vote, including votes delegated to them) toward a specific
    ///   `proposal` argument (`proposals[proposal].name`) associated with
    ///   a `Proposal` in the `proposals`
    /// - `sender` (Voter) must not have already voted
    function vote(uint proposal) {
        Voter sender = voters[msg.sender];
        require(!sender.voted);

        // TODO: Add a `require` to verify that the given `proposal` argument
        // is within the range of the `proposals` array, otherwise throw early
        // (to avoid throwing later and having to revert all changes)

        // TODO: If more than one Delegators (i.e. 2 voters) delegate their
        //   voting weight to a specific Delegatee voter, then as soon as that
        //   Delegatee votes, then their `voted` property is set `true` and then ALL of their
        //   available weight is transferred to a SINGLE `proposal`, which
        //   prevents them from spreading their available weight (voting power)
        //   across multiple proposals that they may wish to support
        sender.voted = true;
        sender.vote = proposal;
        proposals[proposal].voteCount += sender.weight;
    }

    /// @dev Computes `winningProposal` accounting for all previous votes
    ///  - Reference:
    ///    - `constant`
    function winningProposal() constant returns (uint winningProposal) {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal = p;
            }
        }
    }

    /// Calls winningProposal() to get index of winner from `proposals` array then returns `winnerName`
    function winnerName() constant returns (bytes32 winnerName) {
        winnerName = proposals[winningProposal()].name;
    }

    /// Get count of `proposals` dynamic array of structs
    function proposalsCount() constant returns (uint) {
        return proposals.length;
    }

    /// Get specific properties of `Proposal` at index in `proposals`
    function getProposalName(uint index) constant returns (bytes32 proposalName) {
        return proposals[index].name;
    }

    function getProposalVoteCount(uint index) constant returns (uint voteCount) {
        return proposals[index].voteCount;
    }

    /// Get count of `voters`
    function votersCount() constant returns (uint votersCount) {
        return votersCollection.length;
    }

    function getVoter(uint index) constant returns (address, uint, bool, address, uint) {
        address voterAddress = votersCollection[index];
        Voter voter = voters[voterAddress];
        return (voterAddress, voter.weight, voter.voted, voter.delegate, voter.vote);
    }
}