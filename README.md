# 🌟 AI-Generated Content DAO (AIGenDAO)

# How to Run:
1. Install dependencies:
npm install --save-dev @openzeppelin/contracts @nomicfoundation/hardhat-toolbox @openzeppelin/hardhat-upgrades
2. Run the script:
npx hardhat run scripts/aigendao.js --network hardhat

## 🚀 One-Click Participation
1. **Create**: Submit a prompt → AI generates content → Mint as NFT.  
2. **Vote**: Earn tokens for voting on the best content.  
3. **Earn**: Get royalties when your content or votes win.  

## 🔥 Why Users Love It
- **Gas Savings**: Batch voting and optimized transactions.  
- **Auto-Rewards**: Tokens sent directly to your wallet.  
- **No Gatekeeping**: Anyone can participate (no whitelists).  

## 📜 Smart Contract Highlights
| Feature               | Benefit                                  |
|-----------------------|------------------------------------------|
| `vote()`              | Earn 10 tokens per vote                  |
| `batchVote()`         | Vote on 10+ items in one TX              |
| `claimReputationRewards()` | Cash out your reputation quarterly  |

## 🛠️ Tech Stack
- **Tokens**: ERC-721 (NFTs) + ERC-20 (rewards).  
- **Storage**: IPFS + Filecoin (decentralized).  
- **Governance**: Snapshot for gas-free voting.  

## 🌍 Future Plans
- **Mobile App**: Vote on-the-go.  
- **AI Plugin**: Generate content directly in the dApp.  
- **Layer 2**: Migrate to Optimism for near-zero gas fees.

Contract Address - 0x71B236efcC8Dfe7b82E2c26fdcb74CBfE99E8b55


<img width="1470" alt="Screenshot 2025-06-27 at 12 55 25 AM" src="https://github.com/user-attachments/assets/479cc767-8d27-4fba-9eb5-8a0c4a6f3ded" />


## ✅ Features Added:
- Pagination for Top-N Contents
- Sorting by Date & Creator
- Role-Based Moderation (Admin / Moderator)
- Voting Cooldown (1 vote per 1 hour per content)
