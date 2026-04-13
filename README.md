# HAP Bridge — Guapcoin

Smart contract for anchoring **Human Authorship Protocol (HAP)** records on the **Guapcoin blockchain**.

Part of the [HAP-Protocol](https://github.com/HAP-Protocol) organization.

---

## Deployed Contract

| Network | Address |
|---|---|
| GuapcoinX Mainnet (chainId: 71111) | `0xD9208cFe3273CC78D863B2B14E2a597eabB0EE48` |

---

## Overview

The HAP Bridge stores compact authorship fingerprints on-chain. Full HAP records remain off-chain (IPFS) for efficiency — only a SHA-256 hash is anchored, binding the on-chain proof to the off-chain record.

```
Creator → createHAPRecord() → hashHAPRecord() → HAPBridge.anchor()
                                                        ↓
                                              Guapcoin Blockchain
                                         (immutable timestamp + proof)
```

---

## Contract

**`HAPBridge.sol`** — stores per-record fingerprints with:
- `recordId` — unique HAP record identifier
- `contentHash` — SHA-256 of the creative work file
- `hapRecordHash` — SHA-256 of the full HAP JSON record
- `creator` — wallet address of the creator
- `hcs` — Human Contribution Score (× 10000 for integer storage)
- `tier` — authorship tier (1–4)
- `metadataURI` — IPFS link to the full record

---

## Setup

```bash
npm install
cp .env.example .env
# Fill in DEPLOYER_PRIVATE_KEY and Guapcoin RPC URLs
```

---

## Compile

```bash
npm run compile
```

---

## Deploy

```bash
npm run deploy
```

Deploys to GuapcoinX mainnet (chainId: 71111, RPC: https://rpc-mainnet-2.guapcoinx.com)

---

## Anchoring a Record (with SDK)

```typescript
import { createHAPRecord, hashHAPRecord, hashContent } from '@hap-protocol/sdk';
import { ethers } from 'ethers';
import HAPBridgeABI from './artifacts/contracts/HAPBridge.sol/HAPBridge.json';

const provider = new ethers.JsonRpcProvider('https://rpc-mainnet-2.guapcoinx.com');
const signer = new ethers.Wallet(process.env.DEPLOYER_PRIVATE_KEY, provider);
const bridge = new ethers.Contract(BRIDGE_ADDRESS, HAPBridgeABI.abi, signer);

const record = createHAPRecord({ /* ... */ });
const recordHash = hashHAPRecord(record);

const tx = await bridge.anchor(
  ethers.hexlify(ethers.toUtf8Bytes(record.record_id)).padEnd(66, '0'),
  '0x' + record.work.content_hash,
  '0x' + recordHash,
  Math.round(record.hcs * 10000),
  record.tier,
  'ipfs://QmYourIPFSHash'
);

await tx.wait();
console.log('Anchored:', tx.hash);
```

---

## Protocol Links

- [HAP Specification](https://github.com/HAP-Protocol/spec)
- [HAP TypeScript SDK](https://github.com/HAP-Protocol/sdk)
- [Guapcoin Organization](https://github.com/Guapcoin-Org)
- [haphuman.xyz](https://haphuman.xyz)

---

## License

MIT
