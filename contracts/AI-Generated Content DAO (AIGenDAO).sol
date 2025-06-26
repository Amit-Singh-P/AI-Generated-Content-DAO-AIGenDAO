// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ==================== STAGE 1: IMPORTS ====================
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AIGenDAO is ERC721, Ownable {
    // ==================== STAGE 2: SETUP ====================
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    // ==================== STAGE 3: DATA STRUCTURES ====================
    struct Content {
        string prompt;
        string aiModel;
        string ipfsHash;
        address creator;
        uint256 votes;
        uint256 createdAt;
    }

    // ==================== STAGE 4: STATE VARIABLES ====================
    mapping(uint256 => Content) public contents;
    mapping(address => uint256) public creatorReputation;
    mapping(address => mapping(uint256 => bool)) public hasVoted;
    IERC20 public rewardToken;

    // ==================== STAGE 5: EVENTS ====================
    event ContentCreated(uint256 indexed tokenId, address creator, string ipfsHash);
    event Voted(uint256 indexed tokenId, address voter, uint256 newVoteCount);
    event Rewarded(address indexed user, uint256 amount);

    // ==================== STAGE 6: INITIALIZATION ====================
    constructor(address _rewardToken)
        ERC721("AIGenDAONFT", "AIGEN")
        Ownable(msg.sender) 
    {
        rewardToken = IERC20(_rewardToken);
    }

    // ==================== STAGE 7: CORE FUNCTIONS ====================

    /// @notice Submit AI-generated content and mint NFT
    function createContent(
        string calldata prompt,
        string calldata aiModel,
        string calldata ipfsHash
    ) external {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);

        contents[tokenId] = Content({
            prompt: prompt,
            aiModel: aiModel,
            ipfsHash: ipfsHash,
            creator: msg.sender,
            votes: 0,
            createdAt: block.timestamp
        });

        emit ContentCreated(tokenId, msg.sender, ipfsHash);
    }

    /// @notice Vote on content
    function vote(uint256 tokenId) external {
        _vote(tokenId);
    }

    /// @notice Batch vote for multiple contents
    function batchVote(uint256[] calldata tokenIds) external {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _vote(tokenIds[i]);
        }
    }

    function _vote(uint256 tokenId) internal {
        require(ownerOf(tokenId) != address(0), "Content does not exist");
        require(!hasVoted[msg.sender][tokenId], "Already voted");

        Content storage content = contents[tokenId];
        content.votes += 1 + (creatorReputation[msg.sender] / 10);
        hasVoted[msg.sender][tokenId] = true;

        // Reward creator reputation
        creatorReputation[content.creator] += 1;

        // Reward voter
        uint256 reward = 10 * 10**18; // 10 tokens assuming 18 decimals
        require(rewardToken.transfer(msg.sender, reward), "Reward transfer failed");

        emit Voted(tokenId, msg.sender, content.votes);
        emit Rewarded(msg.sender, reward);
    }

    // ==================== STAGE 8: ADMIN FUNCTIONS ====================
    /// @notice Claim accumulated reputation rewards
    function claimReputationRewards() external {
        uint256 rewards = creatorReputation[msg.sender] * 10**18; // 1 rep = 1 token (adjust as needed)
        creatorReputation[msg.sender] = 0;
        require(rewardToken.transfer(msg.sender, rewards), "Transfer failed");
        emit Rewarded(msg.sender, rewards);
    }

    // ==================== STAGE 9: VIEW FUNCTIONS ====================
    function getContent(uint256 tokenId) external view returns (
        string memory prompt,
        string memory aiModel,
        string memory ipfsHash,
        uint256 votes
    ) {
        Content memory content = contents[tokenId];
        return (
            content.prompt,
            content.aiModel,
            content.ipfsHash,
            content.votes
        );
    }
}

