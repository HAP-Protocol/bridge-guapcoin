import { ethers } from 'hardhat';

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log('Deploying HAPBridge with account:', deployer.address);

  const balance = await ethers.provider.getBalance(deployer.address);
  console.log('Account balance:', ethers.formatEther(balance), 'GXC');

  const HAPBridge = await ethers.getContractFactory('HAPBridge');
  const bridge = await HAPBridge.deploy();
  await bridge.waitForDeployment();

  const address = await bridge.getAddress();
  console.log('HAPBridge deployed to:', address);
  console.log('Transaction hash:', bridge.deploymentTransaction()?.hash);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
