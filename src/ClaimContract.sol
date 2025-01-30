// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IssuesContract.sol";

contract ClaimContract {
    IERC20 public lazyToken;
    IssuesContract public issuesContract;

    struct ProofData {
        string prLink;
        bool isMerged;
        address developer;
    }

    struct Response {
        uint256 issueId;
        string prLink;
        uint256 bountyAmount;
        address developer;
        bool isApproved;
        uint256 timestamp;
    }

    mapping(uint256 => ProofData) public claims;
    mapping(string => bool) public usedPRLinks;

    event RewardClaimed(uint256 issueId, address developer, uint256 amount);
    event PRVerified(uint256 issueId, bool isApproved);

    constructor(address _lazyToken, address _issuesContract) {
        lazyToken = IERC20(_lazyToken);
        issuesContract = IssuesContract(_issuesContract);
    }

    function getClaimResponse(
        uint256 issueId
    ) external view returns (Response memory) {
        ProofData memory proof = claims[issueId];
        IssuesContract.Issue memory issue = issuesContract.getIssueDetails(
            issueId
        );

        return
            Response({
                issueId: issueId,
                prLink: proof.prLink,
                bountyAmount: issue.bountyAmount,
                developer: proof.developer,
                isApproved: proof.isMerged,
                timestamp: block.timestamp
            });
    }

    // Update event untuk include lebih banyak data
    event RewardClaimed(
        uint256 indexed issueId,
        address indexed developer,
        string prLink,
        uint256 bountyAmount,
        uint256 timestamp
    );

    function claimReward(
        uint256 issueId,
        string memory prLink,
        bool isMerged
    ) external {
        require(!usedPRLinks[prLink], "PR already used");

        IssuesContract.Issue memory issue = issuesContract.getIssueDetails(
            issueId
        );
        require(issue.isOpen, "Issue closed");
        require(block.timestamp <= issue.deadline, "Deadline passed");
        require(isMerged, "PR not merged");

        claims[issueId] = ProofData(prLink, isMerged, msg.sender);
        usedPRLinks[prLink] = true;

        lazyToken.transferFrom(
            address(issuesContract),
            msg.sender,
            issue.bountyAmount
        );

        emit RewardClaimed(
            issueId,
            msg.sender,
            prLink,
            issue.bountyAmount,
            block.timestamp
        );
        emit PRVerified(issueId, true);
    }

    function verifyMergeStatus(
        string memory prLink
    ) external view returns (bool) {
        return usedPRLinks[prLink];
    }
}
