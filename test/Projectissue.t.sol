// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/ProjectIssue.sol";

contract ProjectIssueTest is Test {
    ProjectIssue public projectIssue;

    function setUp() public {
        projectIssue = new ProjectIssue();
    }

    function testCreateIssue() public {
        projectIssue.createIssue(
            "Test Project",
            "Test Description",
            "http://test.com",
            1000,
            block.timestamp + 1 days
        );

        // Access the Issue struct returned by the public mapping
        ProjectIssue.Issue memory issue = projectIssue.issues(1);

        // Assert each field of the Issue struct
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
        assertEq(
            issue.repoLink,
            "http://test.com",
            "Repo link should be correct"
        );
        assertEq(issue.bountyAmount, 1000, "Bounty amount should be correct");
        assertEq(
            issue.deadline,
            block.timestamp + 1 days,
            "Deadline should be correct"
        );
        assertEq(
            keccak256(bytes(issue.status)),
            keccak256(bytes("Open")),
            "Status should be Open"
        );
    }
}
