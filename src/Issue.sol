// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ProjectIssue.sol";

contract IssueDetails is ProjectIssue {
    function getIssueDetails(
        uint256 issueId
    ) public view returns (Issue memory) {
        return issues[issueId];
    }
}
