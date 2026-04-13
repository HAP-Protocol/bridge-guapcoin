import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';
import * as dotenv from 'dotenv';

dotenv.config();

const DEPLOYER_PRIVATE_KEY = process.env.DEPLOYER_PRIVATE_KEY ?? '';
const GUAPCOIN_TESTNET_RPC = process.env.GUAPCOIN_TESTNET_RPC ?? '';
const GUAPCOIN_MAINNET_RPC = process.env.GUAPCOIN_MAINNET_RPC ?? '';

const config: HardhatUserConfig = {
  solidity: {
    version: '0.8.20',
    settings: {
      optimizer: { enabled: true, runs: 200 },
    },
  },
  networks: {
    hardhat: {},
    guapcoin_testnet: {
      url: GUAPCOIN_TESTNET_RPC,
      accounts: DEPLOYER_PRIVATE_KEY ? [DEPLOYER_PRIVATE_KEY] : [],
      chainId: undefined, // Set once Guapcoin testnet chain ID is confirmed
    },
    guapcoin_mainnet: {
      url: GUAPCOIN_MAINNET_RPC,
      accounts: DEPLOYER_PRIVATE_KEY ? [DEPLOYER_PRIVATE_KEY] : [],
      chainId: undefined, // Set once Guapcoin mainnet chain ID is confirmed
    },
  },
};

export default config;
