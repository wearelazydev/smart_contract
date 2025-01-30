// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Claim {
    mapping(address => mapping(uint256 => bool)) public claimStatus; // developer => issueId => claimed
    mapping(uint256 => uint256) public issueBounties;

    // The function checks whether a PR is merged and validates the claim
    function claimReward(
        uint256 issueId,
        address developer,
        bool isMerged
    ) public {
        require(!claimStatus[developer][issueId], "Reward already claimed");
        require(isMerged, "PR is not merged");

        claimStatus[developer][issueId] = true;
        uint256 rewardAmount = issueBounties[issueId];
        // Transfer the reward to the developer (this can be adjusted to the token you want to reward with)
        payable(developer).transfer(rewardAmount);
    }

    // Add functions to fund the contract with rewards
    function fundIssue(uint256 issueId, uint256 amount) public payable {
        issueBounties[issueId] = amount;
    }
}
