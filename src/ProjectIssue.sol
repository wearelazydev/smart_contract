// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProjectIssue {
    struct Issue {
        uint256 id;
        string projectName;
        string description;
        string repoLink;
        uint256 bountyAmount;
        uint256 deadline;
        string status; // Example statuses: "Open", "Closed"
    }

    mapping(uint256 => Issue) public issues;
    uint256 public issueCount;

    function createIssue(
        string memory _projectName,
        string memory _description,
        string memory _repoLink,
        uint256 _bountyAmount,
        uint256 _deadline
    ) public {
        issueCount++;
        issues[issueCount] = Issue(
            issueCount,
            _projectName,
            _description,
            _repoLink,
            _bountyAmount,
            _deadline,
            "Open"
        );
    }
}
