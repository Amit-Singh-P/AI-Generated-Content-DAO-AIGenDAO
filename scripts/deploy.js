// scripts/aigendao.js
const { ethers } = require("hardhat");

async function main() {
  // ==================== STAGE 1: SETUP ====================
  console.log("🚀 Starting AIGenDAO deployment...");
  
  const [deployer] = await ethers.getSigners();
  console.log(`🔑 Using account: ${deployer.address}`);

  // ==================== STAGE 2: DEPLOY REWARD TOKEN ====================
  console.log("🪙 Deploying reward token...");
  const RewardToken = await ethers.getContractFactory("ERC20Mock");
  const rewardToken = await RewardToken.deploy("AIGen Reward", "AIGR", deployer.address, ethers.parseEther("1000000"));
  await rewardToken.waitForDeployment();
  console.log(`✅ Reward Token deployed to: ${rewardToken.target}`);

  // ==================== STAGE 3: DEPLOY AIGenDAO ====================
  console.log("🖼️ Deploying AIGenDAO contract...");
  const AIGenDAO = await ethers.getContractFactory("AIGenDAO");
  const aigendao = await AIGenDAO.deploy(rewardToken.target);
  await aigendao.waitForDeployment();
  console.log(`✅ AIGenDAO deployed to: ${aigendao.target}`);

  // ==================== STAGE 4: FUND CONTRACT WITH REWARDS ====================
  console.log("💰 Funding contract with reward tokens...");
  const fundAmount = ethers.parseEther("100000");
  await rewardToken.transfer(aigendao.target, fundAmount);
  console.log(`✅ Contract funded with ${ethers.formatEther(fundAmount)} tokens`);

  // ==================== STAGE 5: DEMO INTERACTIONS ====================
  console.log("🎬 Starting demo interactions...");

  // Create content
  console.log("📝 Creating content...");
  const createTx = await aigendao.createContent(
    "A futuristic cityscape at sunset",
    "Stable Diffusion v2.1",
    "QmXyZ123...abc"
  );
  await createTx.wait();
  console.log("✅ Content created (Token ID: 0)");

  // Create second content
  const createTx2 = await aigendao.createContent(
    "Cyberpunk character portrait",
    "Midjourney v5",
    "QmAbC456...def"
  );
  await createTx2.wait();
  console.log("✅ Content created (Token ID: 1)");

  // Vote on content
  console.log("🗳️ Voting on content...");
  const voteTx = await aigendao.vote(0);
  await voteTx.wait();
  console.log("✅ Voted on Token ID 0");

  // Batch vote
  console.log("🗳️ Batch voting...");
  const batchVoteTx = await aigendao.batchVote([0, 1]);
  await batchVoteTx.wait();
  console.log("✅ Batch voted on Token IDs [0, 1]");

  // Check content
  console.log("🔍 Checking content details...");
  const [prompt, aiModel, ipfsHash, votes] = await aigendao.getContent(0);
  console.log(`📋 Content 0 Details:
  Prompt: ${prompt}
  AI Model: ${aiModel}
  IPFS Hash: ${ipfsHash}
  Votes: ${votes}`);

  // Claim reputation rewards
  console.log("🏆 Claiming reputation rewards...");
  const claimTx = await aigendao.claimReputationRewards();
  await claimTx.wait();
  console.log("✅ Reputation rewards claimed");

  // ==================== STAGE 6: VERIFICATION ====================
  console.log("🔎 Verifying contract state...");
  const creatorRep = await aigendao.creatorReputation(deployer.address);
  console.log(`🏅 Creator reputation: ${creatorRep}`);

  const balance = await rewardToken.balanceOf(deployer.address);
  console.log(`💰 Deployer token balance: ${ethers.formatEther(balance)}`);

  console.log("🎉 Deployment and demo completed successfully!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  });
