const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  // Deploy Mock ERC20 Token
  const ERC20Token = await ethers.getContractFactory("MockERC20");
  const erc20Token = await ERC20Token.deploy("Mock Stablecoin", "MSC");
  await erc20Token.waitForDeployment();
  console.log("Mock ERC20 Token deployed to:", erc20Token.target);

  // Deploy Mock ERC721 Token
  const ERC721Token = await ethers.getContractFactory("MockERC721");
  const erc721Token = await ERC721Token.deploy("Mock NFT", "MNFT");
  await erc721Token.waitForDeployment();
  console.log("Mock ERC721 Token deployed to:", erc721Token.target);

  // Deploy Escrow Contract
  const Escrow = await ethers.getContractFactory("Escrow");
  const escrow = await Escrow.deploy(erc20Token.target, erc721Token.target);
  await escrow.waitForDeployment();
  console.log("Escrow Contract deployed to:", escrow.target);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});