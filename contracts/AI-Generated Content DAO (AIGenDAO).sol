// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ==================== STAGE 1: IMPORTS ====================
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AIGenDAO is ERC721, Ownable, AccessControl {
    // ==================== STAGE 2: SETUP ====================
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    bytes32 public constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");

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
    mapping(address => mapping(uint256 => uint256)) public lastVoteTime;
    IERC20 public rewardToken;

    // ==================== STAGE 5: EVENTS ====================
    event ContentCreated(uint256 indexed tokenId, address creator, string ipfsHash);
    event Voted(uint256 indexed tokenId, address voter, uint256 newVoteCount);
    event Rewarded(address indexed user, uint256 amount);
    event ContentRemoved(uint256 indexed tokenId);

    // ==================== STAGE 6: INITIALIZATION ====================
    constructor(address _rewardToken)
        ERC721("AIGenDAONFT", "AIGEN")
        Ownable(msg.sender)
    {
        rewardToken = IERC20(_rewardToken);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // ==================== STAGE 7: CORE FUNCTIONS ====================
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

    function vote(uint256 tokenId) external {
        _vote(tokenId);
    }

    function batchVote(uint256[] calldata tokenIds) external {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _vote(tokenIds[i]);
        }
    }

    function _vote(uint256 tokenId) internal {
        require(ownerOf(tokenId) != address(0), "Invalid content");
        require(block.timestamp - lastVoteTime[msg.sender][tokenId] >= 1 hours, "Cooldown: 1 hour");

        Content storage content = contents[tokenId];
        content.votes += 1 + (creatorReputation[msg.sender] / 10);
        lastVoteTime[msg.sender][tokenId] = block.timestamp;

        creatorReputation[content.creator] += 1;

        uint256 reward = 10 * 10**18;
        require(rewardToken.transfer(msg.sender, reward), "Reward failed");

        emit Voted(tokenId, msg.sender, content.votes);
        emit Rewarded(msg.sender, reward);
    }

    // ==================== STAGE 8: ADMIN / MODERATOR FUNCTIONS ====================
    function addModerator(address mod) external onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(MODERATOR_ROLE, mod);
    }

    function removeModerator(address mod) external onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(MODERATOR_ROLE, mod);
    }

    function deleteContent(uint256 tokenId) external onlyRole(MODERATOR_ROLE) {
        require(_exists(tokenId), "No such token");
        delete contents[tokenId];
        _burn(tokenId);
        emit ContentRemoved(tokenId);
    }

    function claimReputationRewards() external {
        uint256 rewards = creatorReputation[msg.sender] * 10**18;
        creatorReputation[msg.sender] = 0;
        require(rewardToken.transfer(msg.sender, rewards), "Transfer failed");
        emit Rewarded(msg.sender, rewards);
    }

    // ==================== STAGE 9: VIEW FUNCTIONS ====================
    function getContent(uint256 tokenId) external view returns (
        string memory prompt,
        string memory aiModel,
        string memory ipfsHash,
        uint256 votes,
        address creator,
        uint256 createdAt
    ) {
        Content memory content = contents[tokenId];
        return (
            content.prompt,
            content.aiModel,
            content.ipfsHash,
            content.votes,
            content.creator,
            content.createdAt
        );
    }

    function getTopContents(uint256 offset, uint256 limit) external view returns (
        uint256[] memory tokenIds,
        string[] memory prompts,
        uint256[] memory votes
    ) {
        uint256 total = _tokenIdCounter.current();
        uint256 size = limit < total - offset ? limit : total - offset;

        tokenIds = new uint256[](size);
        prompts = new string[](size);
        votes = new uint256[](size);

        // Create temporary array for sorting
        uint256[] memory sorted = new uint256[](total);
        for (uint256 i = 0; i < total; i++) {
            sorted[i] = i;
        }

        // Simple bubble sort (for demo purpose)
        for (uint256 i = 0; i < total; i++) {
            for (uint256 j = i + 1; j < total; j++) {
                if (contents[sorted[j]].votes > contents[sorted[i]].votes) {
                    (sorted[i], sorted[j]) = (sorted[j], sorted[i]);
                }
            }
        }

        for (uint256 i = 0; i < size; i++) {
            uint256 id = sorted[offset + i];
            tokenIds[i] = id;
            prompts[i] = contents[id].prompt;
            votes[i] = contents[id].votes;
        }
    }

    function getContentsByCreator(address creator) external view returns (uint256[] memory) {
        uint256 total = _tokenIdCounter.current();
        uint256 count = 0;

        for (uint256 i = 0; i < total; i++) {
            if (contents[i].creator == creator) {
                count++;
            }
        }

        uint256[] memory creatorIds = new uint256[](count);
        uint256 index = 0;

        for (uint256 i = 0; i < total; i++) {
            if (contents[i].creator == creator) {
                creatorIds[index++] = i;
            }
        }

        return creatorIds;
    }

    function getLatestContents(uint256 limit) external view returns (uint256[] memory latestIds) {
        uint256 total = _tokenIdCounter.current();
        uint256 size = limit < total ? limit : total;
        latestIds = new uint256[](size);

        for (uint256 i = 0; i < size; i++) {
            latestIds[i] = total - 1 - i;
        }
    }
}
