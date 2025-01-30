// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Claim.sol";

contract ClaimTest is Test {
    Claim public claimContract;
    uint256 public issueId = 1;
    address public developer = address(0x123);
    uint256 public rewardAmount = 1000;

    function setUp() public {
        claimContract = new Claim();
        claimContract.fundIssue(issueId, rewardAmount);
    }

    function testClaimReward() public {
        // Fund the issue with a bounty
        claimContract.fundIssue(issueId, rewardAmount);

        // Developer claims reward (ensure PR is merged)
        claimContract.claimReward(issueId, developer, true);

        bool claimed = claimContract.claimStatus(developer, issueId);
        assertTrue(claimed, "Reward should be claimed");
    }

    function testClaimRewardFailsIfNotMerged() public {
        vm.expectRevert("PR is not merged");
        claimContract.claimReward(issueId, developer, false);
    }

    function testClaimRewardFailsIfAlreadyClaimed() public {
        claimContract.claimReward(issueId, developer, true);

        vm.expectRevert("Reward already claimed");
        claimContract.claimReward(issueId, developer, true);
    }
}
