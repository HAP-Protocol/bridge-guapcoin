// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title HAPBridge
 * @notice On-chain anchoring contract for Human Authorship Protocol (HAP) records.
 *         Stores compact authorship fingerprints on the Guapcoin blockchain.
 *
 * @dev Full HAP records are stored off-chain (IPFS). Only a compact fingerprint
 *      is anchored here for gas efficiency. Verification is done by fetching
 *      the off-chain record and comparing its SHA-256 hash to hapRecordHash.
 *
 * Protocol spec: https://github.com/HAP-Protocol/spec
 * SDK: https://github.com/HAP-Protocol/sdk
 */
contract HAPBridge {

    // -------------------------------------------------------------------------
    // Structs
    // -------------------------------------------------------------------------

    struct HAPRecord {
        bytes32 recordId;       // UUID v4 as bytes32
        bytes32 contentHash;    // SHA-256 of the work file
        bytes32 hapRecordHash;  // SHA-256 of the full HAP JSON record
        address creator;        // Creator wallet address
        uint256 hcs;            // HCS * 10000 (e.g. 0.85 => 8500)
        uint8   tier;           // 1–4
        uint256 timestamp;      // Block timestamp at anchoring
        string  metadataURI;    // IPFS URI to full HAP record JSON
    }

    // -------------------------------------------------------------------------
    // Storage
    // -------------------------------------------------------------------------

    /// @notice All anchored HAP records indexed by recordId
    mapping(bytes32 => HAPRecord) public records;

    /// @notice All records anchored by a given creator
    mapping(address => bytes32[]) public creatorRecords;

    /// @notice All records anchored for a given content hash
    mapping(bytes32 => bytes32[]) public contentRecords;

    /// @notice Total number of anchored records
    uint256 public totalRecords;

    // -------------------------------------------------------------------------
    // Events
    // -------------------------------------------------------------------------

    event RecordAnchored(
        bytes32 indexed recordId,
        bytes32 indexed contentHash,
        address indexed creator,
        uint256 hcs,
        uint8   tier,
        uint256 timestamp
    );

    // -------------------------------------------------------------------------
    // Errors
    // -------------------------------------------------------------------------

    error RecordAlreadyAnchored(bytes32 recordId);
    error InvalidHCS(uint256 hcs);
    error InvalidTier(uint8 tier);
    error InvalidHash(string field);

    // -------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------

    /**
     * @notice Anchor a HAP authorship record on-chain.
     * @param recordId       UUID v4 of the HAP record (as bytes32)
     * @param contentHash    SHA-256 of the work file
     * @param hapRecordHash  SHA-256 of the full HAP JSON record
     * @param hcs            Human Contribution Score * 10000 (0–10000)
     * @param tier           HCS tier classification (1–4)
     * @param metadataURI    IPFS URI to the full HAP record JSON
     */
    function anchor(
        bytes32 recordId,
        bytes32 contentHash,
        bytes32 hapRecordHash,
        uint256 hcs,
        uint8   tier,
        string calldata metadataURI
    ) external {
        if (records[recordId].timestamp != 0) revert RecordAlreadyAnchored(recordId);
        if (hcs > 10000) revert InvalidHCS(hcs);
        if (tier < 1 || tier > 4) revert InvalidTier(tier);
        if (contentHash == bytes32(0)) revert InvalidHash("contentHash");
        if (hapRecordHash == bytes32(0)) revert InvalidHash("hapRecordHash");

        HAPRecord memory record = HAPRecord({
            recordId:      recordId,
            contentHash:   contentHash,
            hapRecordHash: hapRecordHash,
            creator:       msg.sender,
            hcs:           hcs,
            tier:          tier,
            timestamp:     block.timestamp,
            metadataURI:   metadataURI
        });

        records[recordId] = record;
        creatorRecords[msg.sender].push(recordId);
        contentRecords[contentHash].push(recordId);
        totalRecords++;

        emit RecordAnchored(recordId, contentHash, msg.sender, hcs, tier, block.timestamp);
    }

    /**
     * @notice Get a HAP record by its recordId.
     */
    function getRecord(bytes32 recordId) external view returns (HAPRecord memory) {
        return records[recordId];
    }

    /**
     * @notice Get all record IDs anchored by a creator.
     */
    function getCreatorRecords(address creator) external view returns (bytes32[] memory) {
        return creatorRecords[creator];
    }

    /**
     * @notice Get all record IDs anchored for a content hash.
     */
    function getContentRecords(bytes32 contentHash) external view returns (bytes32[] memory) {
        return contentRecords[contentHash];
    }

    /**
     * @notice Verify that a fetched HAP record JSON matches what was anchored.
     * @param recordId        The record to verify
     * @param candidateHash   SHA-256 of the fetched JSON (computed off-chain)
     * @return true if the hashes match
     */
    function verify(bytes32 recordId, bytes32 candidateHash) external view returns (bool) {
        return records[recordId].hapRecordHash == candidateHash;
    }
}
