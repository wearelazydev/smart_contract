// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/LazyToken.sol";
import "../src/IssuesContract.sol";
import "../src/ClaimContract.sol";

contract LazyTokenTest is Test {
    LazyToken public lazyToken;
    address public owner = address(1);
    address public user = address(2);

    function setUp() public {
        vm.startPrank(owner);
        lazyToken = new LazyToken();
        vm.stopPrank();
    }

    function testInitialSupply() public view {
        assertEq(
            lazyToken.balanceOf(owner),
            1_000_000 * 10 ** lazyToken.decimals()
        );
    }

    function testTokenTransfer() public {
        uint256 transferAmount = 1000;
        vm.prank(owner);
        lazyToken.transfer(user, transferAmount);
        assertEq(lazyToken.balanceOf(user), transferAmount);
        assertEq(
            lazyToken.balanceOf(owner),
            1_000_000 * 10 ** lazyToken.decimals() - transferAmount
        );
    }
}

contract IssuesContractTest is Test {
    LazyToken public lazyToken;
    IssuesContract public issuesContract;
    address public owner = address(1);
    address public user = address(2);

    function setUp() public {
        vm.startPrank(owner);
        lazyToken = new LazyToken();
        issuesContract = new IssuesContract(address(lazyToken));
        vm.stopPrank();
    }

    function testCreateIssue() public {
        vm.startPrank(owner);
        uint256 bountyAmount = 1000;
        lazyToken.approve(address(issuesContract), bountyAmount);
        issuesContract.createIssue(
            "GH123",
            bountyAmount,
            "Lazy Project",
            "Test Description",
            "https://github.com/test/repo",
            block.timestamp + 1 days
        );
        IssuesContract.Issue memory issue = issuesContract.getIssueDetails(0);
        assertEq(issue.bountyAmount, bountyAmount);
        assertEq(issue.repoLink, "https://github.com/test/repo");
        assertEq(lazyToken.balanceOf(address(issuesContract)), bountyAmount);
        vm.stopPrank();
    }

    function test_RevertWhen_CreateIssueWithoutApproval() public {
        vm.startPrank(owner);
        vm.expectRevert();
        issuesContract.createIssue(
            "GH123",
            1000,
            "Lazy Project",
            "Test Description",
            "https://github.com/test/repo",
            block.timestamp + 1 days
        );
        vm.stopPrank();
    }
}

contract ClaimContractTest is Test {
    LazyToken public lazyToken;
    IssuesContract public issuesContract;
    ClaimContract public claimContract;
    address public owner = address(1);
    address public developer = address(2);

    function setUp() public {
        // Deploy contracts as owner
        vm.startPrank(owner);
        lazyToken = new LazyToken();
        issuesContract = new IssuesContract(address(lazyToken));
        claimContract = new ClaimContract(
            address(lazyToken),
            address(issuesContract)
        );

        // Create initial issue
        uint256 bountyAmount = 1000;
        lazyToken.approve(address(issuesContract), bountyAmount);
        issuesContract.createIssue(
            "GH123",
            bountyAmount,
            "Lazy Project",
            "Test Description",
            "https://github.com/test/repo",
            block.timestamp + 1 days
        );
        vm.stopPrank();

        // Approve ClaimContract to spend tokens from IssuesContract
        vm.prank(address(issuesContract));
        lazyToken.approve(address(claimContract), bountyAmount);
    }

    function testClaimReward() public {
        vm.startPrank(developer);
        uint256 issueId = 0;
        string memory prLink = "https://github.com/test/repo/pull/1";

        // Simulate backend verification
        claimContract.claimReward(issueId, prLink, true);

        // Check balances
        assertEq(lazyToken.balanceOf(developer), 1000);
        assertTrue(claimContract.verifyMergeStatus(prLink));

        // Check response
        ClaimContract.Response memory response = claimContract.getClaimResponse(
            issueId
        );
        assertEq(response.issueId, issueId);
        assertEq(response.prLink, prLink);
        assertEq(response.bountyAmount, 1000);
        assertEq(response.developer, developer);
        assertTrue(response.isApproved);

        vm.stopPrank();
    }

    function test_RevertWhen_ClaimUnmergedPR() public {
        vm.startPrank(developer);
        uint256 issueId = 0;
        string memory prLink = "https://github.com/test/repo/pull/1";

        // Expect revert karena PR belum di-merge
        vm.expectRevert();
        claimContract.claimReward(issueId, prLink, false);

        vm.stopPrank();
    }

    function test_RevertWhen_ClaimWithUsedPR() public {
        vm.startPrank(developer);
        uint256 issueId = 0;
        string memory prLink = "https://github.com/test/repo/pull/1";

        // Pertama kali berhasil
        claimContract.claimReward(issueId, prLink, true);

        // Expect revert karena PR sudah digunakan
        vm.expectRevert();
        claimContract.claimReward(issueId, prLink, true);

        vm.stopPrank();
    }
}
