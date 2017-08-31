pragma solidity ^0.4.11;

contract CrowdFunding {
    // Define new type with two fields
    struct Funder {
        address addr;
        uint amount;
    }

    // Note: Access members of the struct without assigning to local variable
    // i.e. `campaigns[campaignID].amount = 0`
    struct Campaign {
        address beneficiary;
        uint fundingGoal;
        uint numFunders;
        uint amount;
        mapping (uint => Funder) funders;
    }

    uint numCampaigns;
    mapping (uint => Campaign) campaigns;

    function newCampaign(address beneficiary, uint goal) returns (uint campaignID) {
        campaignID = numCampaigns++;
        // Creates new struct and saves in "storage". Exclude mapping type.
        campaigns[campaignID] = Campaign(beneficiary, goal, 0, 0);
    }

    function contribute(uint campaignID) payable {
        Campaign storage c = campaigns[campaignID]; // "storage"
        // Creates new struct temporary "memory". Initialise with given values and copies to "storage"

        // Initialise Funder and append to funders. Alternative approach is simply `Funder(msg.sender, msg.value)`.
        // Assign the struct type to a local variable (with default "storage" Data Location) storing a reference
        // so assignments to members of the local variable actually write to the state.
        c.funders[c.numFunders++] = Funder({addr: msg.sender, amount: msg.value});
        c.amount += msg.value;
    }

    function checkGoalReached(uint campaignID) returns (bool reached) {
        Campaign storage c = campaigns[campaignID];
        if (c.amount < c.fundingGoal)
            return false;
        uint amount = c.amount;
        c.amount = 0;
        c.beneficiary.transfer(amount);
        return true;
    }
}