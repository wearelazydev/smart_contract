// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract IssuesContract {
    struct Issue {
        uint256 id;
        string githubProjectId;
        uint256 bountyAmount;
        string projectName;
        string description;
        string repoLink;
        uint256 deadline;
        bool isOpen;
        address owner;
    }

    IERC20 public lazyToken;
    uint256 public issueCount;
    mapping(uint256 => Issue) public issues;

    constructor(address _lazyToken) {
        lazyToken = IERC20(_lazyToken);
    }

    function createIssue(
        string memory _githubProjectId,
        uint256 _bountyAmount,
        string memory _projectName,
        string memory _description,
        string memory _repoLink,
        uint256 _deadline
    ) external {
        require(_bountyAmount > 0, "Bounty amount must be greater than 0");
        require(_deadline > block.timestamp, "Deadline must be in the future");

        // Transfer bounty dari pemilik ke kontrak
        require(
            lazyToken.transferFrom(msg.sender, address(this), _bountyAmount),
            "Transfer failed"
        );

        // Simpan detail issue
        issues[issueCount] = Issue({
            id: issueCount,
            githubProjectId: _githubProjectId,
            bountyAmount: _bountyAmount,
            projectName: _projectName,
            description: _description,
            repoLink: _repoLink,
            deadline: _deadline,
            isOpen: true,
            owner: msg.sender
        });

        issueCount++;
    }

    function getIssueDetails(
        uint256 _issueId
    ) external view returns (Issue memory) {
        require(_issueId < issueCount, "Invalid issue ID");
        return issues[_issueId];
    }
}
