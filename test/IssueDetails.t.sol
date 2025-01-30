// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Issue.sol";

contract IssueDetailsTest is Test {
    IssueDetails public issueDetails;

    function setUp() public {
        issueDetails = new IssueDetails();
        issueDetails.createIssue(
            "Test Project",
            "Test Description",
            "http://test.com",
            1000,
            block.timestamp + 1 days
        );
    }

    function testGetIssueDetails() public {
        IssueDetails.Issue memory issue = issueDetails.getIssueDetails(1);

        assertEq(issue.id, 1, "Issue ID should be correct");
        assertEq(
            issue.projectName,
            "Test Project",
            "Project name should be correct"
        );
        assertEq(
            issue.description,
            "Test Description",
            "Description should be correct"
        );
    }
}
