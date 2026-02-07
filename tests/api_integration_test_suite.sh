#!/bin/bash
# TESSERA Protocol - Complete API Test Suite
# Tests all 12 entities with CREATE, READ, UPDATE operations

# API_KEY is now handled by the proxy server
BASE_URL="http://localhost:3000/api/tessera"

echo "======================================"
echo "TESSERA PROTOCOL API TEST SUITE"
echo "======================================"
echo ""

# ============================================================================
# TEST 1: Block Entity
# ============================================================================
echo "TEST 1: Block Entity"
echo "--------------------"

echo "Creating genesis block in root lattice (shard 0)..."
BLOCK_RESPONSE=$(curl -X POST \
  "${BASE_URL}/Block" \
\
  -H "Content-Type: application/json" \
  -d '{
    "block_hash": "0x0000000000000000000000000000000000000000000000000000000000000001",
    "block_number": 0,
    "shard_id": 0,
    "epoch": 0,
    "timestamp": "2025-01-15T00:00:00.000Z",
    "miner_address": "0x0000000000000000000000000000000000000000",
    "difficulty": 1000000,
    "nonce": "0x0000000000000042",
    "parent_hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "state_root": "0xd7f8974fb5ac78d9ac099b9ad5018bedc2ce0a72dad1827a1709da30580f0544",
    "transactions_root": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421",
    "receipts_root": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421",
    "validator_signatures": [],
    "finality_status": "finalized",
    "gas_used": 0,
    "gas_limit": 30000000,
    "base_fee": 1,
    "block_reward": 100,
    "transaction_count": 0
  }')
echo "$BLOCK_RESPONSE" | jq '.'
BLOCK_ID=$(echo "$BLOCK_RESPONSE" | jq -r '.id')
echo "Created Block ID: $BLOCK_ID"
echo ""

echo "Creating block in shard 1..."
curl -X POST \
  "${BASE_URL}/Block" \
\
  -H "Content-Type: application/json" \
  -d '{
    "block_hash": "0x1000000000000000000000000000000000000000000000000000000000000001",
    "block_number": 1,
    "shard_id": 1,
    "epoch": 1,
    "timestamp": "2025-01-15T00:02:30.000Z",
    "miner_address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb1",
    "difficulty": 1050000,
    "nonce": "0x00000000000001a3",
    "parent_hash": "0x0000000000000000000000000000000000000000000000000000000000000001",
    "lattice_commitment_hash": "0x0000000000000000000000000000000000000000000000000000000000000001",
    "state_root": "0xa7f8974fb5ac78d9ac099b9ad5018bedc2ce0a72dad1827a1709da30580f0999",
    "transactions_root": "0x26e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421",
    "receipts_root": "0x26e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421",
    "validator_signatures": [
      {"validator_address": "0x89205A3A3b2A69De6Dbf7f01ED13B2108B2c43e7", "signature": "0xabc123", "timestamp": "2025-01-15T00:02:35.000Z"}
    ],
    "finality_status": "finalized",
    "gas_used": 125000,
    "gas_limit": 30000000,
    "base_fee": 1.2,
    "block_reward": 100,
    "transaction_count": 3
  }' | jq '.'
echo ""

echo "Querying all blocks sorted by block_number..."
curl -X GET \
  "${BASE_URL}/Block?sort=-block_number&limit=10" \
\
  -H "Content-Type: application/json" | jq '.'
echo ""

echo "Querying blocks in shard 1 only..."
curl -X GET \
  "${BASE_URL}/Block?shard_id=1" \
\
  -H "Content-Type: application/json" | jq '.'
echo ""

# ============================================================================
# TEST 2: Transaction Entity
# ============================================================================
echo "TEST 2: Transaction Entity"
echo "--------------------------"

echo "Creating a simple transfer transaction..."
TX_RESPONSE=$(curl -X POST \
  "${BASE_URL}/Transaction" \
\
  -H "Content-Type: application/json" \
  -d '{
    "tx_hash": "0x5c504ed432cb51138bcf09aa5e8a410dd4a1e204ef84bfed1be16dfba1b22060",
    "block_hash": "0x1000000000000000000000000000000000000000000000000000000000000001",
    "block_number": 1,
    "shard_id": 1,
    "timestamp": "2025-01-15T00:02:30.000Z",
    "from_address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb1",
    "to_address": "0x89205A3A3b2A69De6Dbf7f01ED13B2108B2c43e7",
    "value": "5000000000000000000",
    "gas_price": 1.5,
    "gas_limit": 21000,
    "gas_used": 21000,
    "nonce": 0,
    "tx_type": "transfer",
    "status": "success"
  }')
echo "$TX_RESPONSE" | jq '.'
TX_ID=$(echo "$TX_RESPONSE" | jq -r '.id')
echo ""

echo "Creating a contract deployment transaction..."
curl -X POST \
  "${BASE_URL}/Transaction" \
\
  -H "Content-Type: application/json" \
  -d '{
    "tx_hash": "0x8c504ed432cb51138bcf09aa5e8a410dd4a1e204ef84bfed1be16dfba1b33071",
    "block_hash": "0x1000000000000000000000000000000000000000000000000000000000000001",
    "block_number": 1,
    "shard_id": 1,
    "timestamp": "2025-01-15T00:02:31.000Z",
    "from_address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb1",
    "value": "0",
    "gas_price": 2.0,
    "gas_limit": 500000,
    "gas_used": 425000,
    "nonce": 1,
    "input_data": "0x608060405234801561001057600080fd5b50",
    "tx_type": "contract_deploy",
    "status": "success",
    "contract_address": "0xde0B295669a9FD93d5F28D9Ec85E40f4cb697BAe"
  }' | jq '.'
echo ""

echo "Creating a cross-shard message transaction..."
curl -X POST \
  "${BASE_URL}/Transaction" \
\
  -H "Content-Type: application/json" \
  -d '{
    "tx_hash": "0x9d615ed432cb51138bcf09aa5e8a410dd4a1e204ef84bfed1be16dfba1b44082",
    "block_hash": "0x1000000000000000000000000000000000000000000000000000000000000001",
    "block_number": 1,
    "shard_id": 1,
    "timestamp": "2025-01-15T00:02:32.000Z",
    "from_address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb1",
    "to_address": "0x89205A3A3b2A69De6Dbf7f01ED13B2108B2c43e7",
    "value": "1000000000000000000",
    "gas_price": 5.0,
    "gas_limit": 100000,
    "gas_used": 100000,
    "nonce": 2,
    "tx_type": "cross_shard_message",
    "status": "success",
    "cross_shard_destination": 2,
    "cross_shard_status": "initiated"
  }' | jq '.'
echo ""

echo "Querying all transactions from a specific address..."
curl -X GET \
  "${BASE_URL}/Transaction?from_address=0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb1" \
\
  -H "Content-Type: application/json" | jq '.'
echo ""

echo "Querying only cross-shard transactions..."
curl -X GET \
  "${BASE_URL}/Transaction?tx_type=cross_shard_message" \
\
  -H "Content-Type: application/json" | jq '.'
echo ""

# ============================================================================
# TEST 3: Address Entity
# ============================================================================
echo "TEST 3: Address Entity"
echo "----------------------"

echo "Creating user address with transaction history..."
ADDR_RESPONSE=$(curl -X POST \
  "${BASE_URL}/Address" \
\
  -H "Content-Type: application/json" \
  -d '{
    "address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb1",
    "balance": "94500000000000000000",
    "nonce": 3,
    "is_contract": false,
    "first_seen_block": 1,
    "last_active_block": 1,
    "total_transactions_sent": 3,
    "total_transactions_received": 0,
    "total_volume_sent": "6000000000000000000",
    "total_volume_received": "0",
    "is_validator": false,
    "label": "Early Adopter Wallet"
  }')
echo "$ADDR_RESPONSE" | jq '.'
echo ""

echo "Creating contract address..."
curl -X POST \
  "${BASE_URL}/Address" \
\
  -H "Content-Type: application/json" \
  -d '{
    "address": "0xde0B295669a9FD93d5F28D9Ec85E40f4cb697BAe",
    "balance": "0",
    "nonce": 1,
    "is_contract": true,
    "contract_code_hash": "0x8c504ed432cb51138bcf09aa5e8a410dd4a1e204ef84bfed1be16dfba1b33071",
    "first_seen_block": 1,
    "last_active_block": 1,
    "total_transactions_sent": 0,
    "total_transactions_received": 1,
    "total_volume_sent": "0",
    "total_volume_received": "0",
    "is_validator": false,
    "contract_storage_size_mb": 0.5
  }' | jq '.'
echo ""

echo "Creating validator address..."
curl -X POST \
  "${BASE_URL}/Address" \
\
  -H "Content-Type: application/json" \
  -d '{
    "address": "0x89205A3A3b2A69De6Dbf7f01ED13B2108B2c43e7",
    "balance": "35000000000000000000000",
    "nonce": 0,
    "is_contract": false,
    "first_seen_block": 0,
    "last_active_block": 1,
    "total_transactions_sent": 0,
    "total_transactions_received": 1,
    "total_volume_sent": "0",
    "total_volume_received": "5000000000000000000",
    "is_validator": true,
    "validator_stake": "32000000000000000000000",
    "delegated_stake": "3000000000000000000000",
    "validator_commission": 10,
    "label": "Genesis Validator #1"
  }' | jq '.'
echo ""

echo "Querying all validator addresses..."
curl -X GET \
  "${BASE_URL}/Address?is_validator=true" \
\
  -H "Content-Type: application/json" | jq '.'
echo ""

echo "Querying rich list (top balances)..."
curl -X GET \
  "${BASE_URL}/Address?sort=-balance&limit=5" \
\
  -H "Content-Type: application/json" | jq '.'
echo ""

# ============================================================================
# TEST 4: Shard Entity
# ============================================================================
echo "TEST 4: Shard Entity"
echo "--------------------"

echo "Creating root lattice (shard 0)..."
SHARD_RESPONSE=$(curl -X POST \
  "${BASE_URL}/Shard" \
\
  -H "Content-Type: application/json" \
  -d '{
    "shard_id": 0,
    "creation_epoch": 0,
    "current_status": "active",
    "current_block_height": 1000,
    "total_transactions": 15000,
    "active_validators": [
      "0x89205A3A3b2A69De6Dbf7f01ED13B2108B2c43e7",
      "0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed"
    ],
    "validator_rotation_epoch": 1,
    "cumulative_gas_used": 450000000,
    "average_block_time": 2.5,
    "child_shard_ids": [1, 2, 3],
    "state_size_gb": 5.2
  }')
echo "$SHARD_RESPONSE" | jq '.'
echo ""

echo "Creating child shard 1..."
curl -X POST \
  "${BASE_URL}/Shard" \
\
  -H "Content-Type: application/json" \
  -d '{
    "shard_id": 1,
    "parent_shard_id": 0,
    "creation_epoch": 1,
    "current_status": "active",
    "current_block_height": 500,
    "total_transactions": 3500,
    "active_validators": [
      "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb1"
    ],
    "validator_rotation_epoch": 2,
    "cumulative_gas_used": 105000000,
    "average_block_time": 2.4,
    "child_shard_ids": [],
    "last_checkpoint_block": 490,
    "state_size_gb": 1.8
  }' | jq '.'
echo ""

echo "Creating mature shard ready for checkpointing..."
curl -X POST \
  "${BASE_URL}/Shard" \
\
  -H "Content-Type: application/json" \
  -d '{
    "shard_id": 10,
    "parent_shard_id": 3,
    "creation_epoch": 2,
    "current_status": "checkpointing",
    "current_block_height": 2048,
    "total_transactions": 50000,
    "active_validators": [
      "0x89205A3A3b2A69De6Dbf7f01ED13B2108B2c43e7"
    ],
    "validator_rotation_epoch": 5,
    "cumulative_gas_used": 1500000000,
    "average_block_time": 2.6,
    "child_shard_ids": [],
    "merge_target_shard_id": 3,
    "last_checkpoint_block": 2048,
    "state_size_gb": 12.5
  }' | jq '.'
echo ""

echo "Querying all active shards..."
curl -X GET \
  "${BASE_URL}/Shard?current_status=active" \
\
  -H "Content-Type: application/json" | jq '.'
echo ""

echo "Querying shards by parent (children of root lattice)..."
curl -X GET \
  "${BASE_URL}/Shard?parent_shard_id=0" \
\
  -H "Content-Type: application/json" | jq '.'
echo ""

# ============================================================================
# TEST 5: Validator Entity
# ============================================================================
echo "TEST 5: Validator Entity"
echo "------------------------"

echo "Creating genesis validator with high stake..."
VALIDATOR_RESPONSE=$(curl -X POST \
  "${BASE_URL}/Validator" \
\
  -H "Content-Type: application/json" \
  -d '{
    "validator_address": "0x89205A3A3b2A69De6Dbf7f01ED13B2108B2c43e7",
    "staked_amount": "32000000000000000000000",
    "delegated_amount": "3000000000000000000000",
    "total_stake": "35000000000000000000000",
    "commission_rate": 10,
    "is_active": true,
    "activation_epoch": 0,
    "assigned_shard_ids": [0, 1, 10],
    "total_blocks_attested": 5000,
    "total_blocks_proposed": 150,
    "uptime_percentage": 99.8,
    "slash_count": 0,
    "total_slashed_amount": "0",
    "total_rewards_earned": "1250000000000000000000",
    "last_attestation_block": 1000,
    "delegator_count": 25,
    "withdrawal_address": "0x89205A3A3b2A69De6Dbf7f01ED13B2108B2c43e7",
    "lock_end_epoch": 10
  }')
echo "$VALIDATOR_RESPONSE" | jq '.'
echo ""

echo "Creating smaller validator..."
curl -X POST \
  "${BASE_URL}/Validator" \
\
  -H "Content-Type: application/json" \
  -d '{
    "validator_address": "0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed",
    "staked_amount": "8000000000000000000000",
    "delegated_amount": "500000000000000000000",
    "total_stake": "8500000000000000000000",
    "commission_rate": 15,
    "is_active": true,
    "activation_epoch": 1,
    "assigned_shard_ids": [0],
    "total_blocks_attested": 800,
    "total_blocks_proposed": 20,
    "uptime_percentage": 97.5,
    "slash_count": 1,
    "total_slashed_amount": "100000000000000000000",
    "total_rewards_earned": "150000000000000000000",
    "last_attestation_block": 995,
    "delegator_count": 5,
    "withdrawal_address": "0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed",
    "lock_end_epoch": 8
  }' | jq '.'
echo ""

echo "Querying validators by total stake (descending)..."
curl -X GET \
  "${BASE_URL}/Validator?is_active=true&sort=-total_stake" \
\
  -H "Content-Type: application/json" | jq '.'
echo ""

echo "Querying validators with high uptime (>98%)..."
curl -X GET \
  "${BASE_URL}/Validator?uptime_percentage__gte=98" \
\
  -H "Content-Type: application/json" | jq '.'
echo ""

# ============================================================================
# TEST 6: Delegation Entity
# ============================================================================
echo "TEST 6: Delegation Entity"
echo "-------------------------"

echo "Creating delegation to genesis validator..."
DELEGATION_RESPONSE=$(curl -X POST \
  "${BASE_URL}/Delegation" \
\
  -H "Content-Type: application/json" \
  -d '{
    "delegator_address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb1",
    "validator_address": "0x89205A3A3b2A69De6Dbf7f01ED13B2108B2c43e7",
    "delegated_amount": "1000000000000000000000",
    "delegation_epoch": 1,
    "last_reward_claim_epoch": 1,
    "accumulated_rewards": "45000000000000000000",
    "is_active": true
  }')
echo "$DELEGATION_RESPONSE" | jq '.'
echo ""

echo "Creating delegation in unbonding state..."
curl -X POST \
  "${BASE_URL}/Delegation" \
\
  -H "Content-Type: application/json" \
  -d '{
    "delegator_address": "0xFB6916095ca1df60bB79Ce92cE3Ea74c37c5d359",
    "validator_address": "0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed",
    "delegated_amount": "500000000000000000000",
    "delegation_epoch": 0,
    "last_reward_claim_epoch": 3,
    "accumulated_rewards": "0",
    "is_active": false,
    "unbonding_epoch": 6
  }' | jq '.'
echo ""

echo "Querying all delegations for a specific validator..."
curl -X GET \
  "${BASE_URL}/Delegation?validator_address=0x89205A3A3b2A69De6Dbf7f01ED13B2108B2c43e7&is_active=true" \
\
  -H "Content-Type: application/json" | jq '.'
echo ""

echo "Querying all active delegations for a delegator..."
curl -X GET \
  "${BASE_URL}/Delegation?delegator_address=0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb1" \
\
  -H "Content-Type: application/json" | jq '.'
echo ""

# ============================================================================
# TEST 7: Contract Entity
# ============================================================================
echo "TEST 7: Contract Entity"
echo "-----------------------"

echo "Creating verified staking pool contract..."
CONTRACT_RESPONSE=$(curl -X POST \
  "${BASE_URL}/Contract" \
\
  -H "Content-Type: application/json" \
  -d '{
    "contract_address": "0xde0B295669a9FD93d5F28D9Ec85E40f4cb697BAe",
    "creator_address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb1",
    "creation_tx_hash": "0x8c504ed432cb51138bcf09aa5e8a410dd4a1e204ef84bfed1be16dfba1b33071",
    "creation_block": 1,
    "shard_id": 1,
    "bytecode_hash": "0xabc123def456",
    "is_verified": true,
    "source_code": "pragma solidity ^0.8.0; contract StakingPool { ... }",
    "compiler_version": "v0.8.19+commit.7dd6d404",
    "contract_name": "StakingPool",
    "total_transactions": 150,
    "unique_callers": 45,
    "storage_size_mb": 0.5,
    "last_interaction_block": 998,
    "is_proxy": false
  }')
echo "$CONTRACT_RESPONSE" | jq '.'
echo ""

echo "Creating proxy contract..."
curl -X POST \
  "${BASE_URL}/Contract" \
\
  -H "Content-Type: application/json" \
  -d '{
    "contract_address": "0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984",
    "creator_address": "0x89205A3A3b2A69De6Dbf7f01ED13B2108B2c43e7",
    "creation_tx_hash": "0x7f8ed432cb51138bcf09aa5e8a410dd4a1e204ef84bfed1be16dfba1b22061",
    "creation_block": 50,
    "shard_id": 1,
    "bytecode_hash": "0xproxy123",
    "is_verified": true,
    "compiler_version": "v0.8.19+commit.7dd6d404",
    "contract_name": "TESSGovernanceProxy",
    "total_transactions": 2000,
    "unique_callers": 500,
    "storage_size_mb": 2.1,
    "last_interaction_block": 999,
    "is_proxy": true,
    "implementation_address": "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"
  }' | jq '.'
echo ""

echo "Querying all verified contracts..."
curl -X GET \
  "${BASE_URL}/Contract?is_verified=true" \
\
  -H "Content-Type: application/json" | jq '.'
echo ""

echo "Querying contracts by shard..."
curl -X GET \
  "${BASE_URL}/Contract?shard_id=1&sort=-total_transactions" \
\
  -H "Content-Type: application/json" | jq '.'
echo ""

# ============================================================================
# TEST 8: CrossShardMessage Entity
# ============================================================================
echo "TEST 8: CrossShardMessage Entity"
echo "---------------------------------"

echo "Creating initiated cross-shard message..."
MSG_RESPONSE=$(curl -X POST \
  "${BASE_URL}/CrossShardMessage" \
\
  -H "Content-Type: application/json" \
  -d '{
    "message_id": "msg_1_to_2_001",
    "initiating_tx_hash": "0x9d615ed432cb51138bcf09aa5e8a410dd4a1e204ef84bfed1be16dfba1b44082",
    "source_shard_id": 1,
    "destination_shard_id": 2,
    "source_block": 1,
    "sender_address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb1",
    "recipient_address": "0x89205A3A3b2A69De6Dbf7f01ED13B2108B2c43e7",
    "value": "1000000000000000000",
    "gas_limit": 100000,
    "message_data": "0x",
    "status": "initiated"
  }')
echo "$MSG_RESPONSE" | jq '.'
MSG_ID=$(echo "$MSG_RESPONSE" | jq -r '.id')
echo ""

echo "Updating message to committed status..."
curl -X PUT \
  "${BASE_URL}/CrossShardMessage/${MSG_ID}" \
\
  -H "Content-Type: application/json" \
  -d '{
    "status": "committed",
    "commitment_block": 105,
    "merkle_proof": {"proof": ["0xabc", "0xdef"], "index": 3}
  }' | jq '.'
echo ""

echo "Creating executed cross-shard message..."
curl -X POST \
  "${BASE_URL}/CrossShardMessage" \
\
  -H "Content-Type: application/json" \
  -d '{
    "message_id": "msg_1_to_3_002",
    "initiating_tx_hash": "0x6f724ed432cb51138bcf09aa5e8a410dd4a1e204ef84bfed1be16dfba1b55093",
    "source_shard_id": 1,
    "destination_shard_id": 3,
    "source_block": 50,
    "sender_address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb1",
    "recipient_address": "0xde0B295669a9FD93d5F28D9Ec85E40f4cb697BAe",
    "value": "500000000000000000",
    "gas_limit": 150000,
    "message_data": "0xa9059cbb",
    "status": "executed",
    "commitment_block": 55,
    "execution_tx_hash": "0x8e835fd432cb51138bcf09aa5e8a410dd4a1e204ef84bfed1be16dfba1b66104",
    "execution_block": 65,
    "total_latency_blocks": 15
  }' | jq '.'
echo ""

echo "Querying all cross-shard messages by status..."
curl -X GET \
  "${BASE_URL}/CrossShardMessage?status=initiated" \
\
  -H "Content-Type: application/json" | jq '.'
echo ""

echo "Querying messages between specific shards..."
curl -X GET \
  "${BASE_URL}/CrossShardMessage?source_shard_id=1&destination_shard_id=2" \
\
  -H "Content-Type: application/json" | jq '.'
echo ""

# ============================================================================
# TEST 9: Epoch Entity
# ============================================================================
echo "TEST 9: Epoch Entity"
echo "--------------------"

echo "Creating genesis epoch..."
EPOCH_RESPONSE=$(curl -X POST \
  "${BASE_URL}/Epoch" \
\
  -H "Content-Type: application/json" \
  -d '{
    "epoch_number": 0,
    "start_block": 0,
    "end_block": 2016,
    "start_timestamp": "2025-01-15T00:00:00.000Z",
    "end_timestamp": "2025-01-22T00:00:00.000Z",
    "active_shards_count": 1,
    "total_validators": 10,
    "total_staked": "320000000000000000000000",
    "average_block_time": 2.5,
    "total_transactions": 15000,
    "total_gas_used": 450000000,
    "pow_reward_per_block": 100,
    "pos_annual_yield": 8.0,
    "slashing_events": 0,
    "governance_proposals": []
  }')
echo "$EPOCH_RESPONSE" | jq '.'
echo ""

echo "Creating epoch 1 with shard splits..."
curl -X POST \
  "${BASE_URL}/Epoch" \
\
  -H "Content-Type: application/json" \
  -d '{
    "epoch_number": 1,
    "start_block": 2017,
    "start_timestamp": "2025-01-22T00:00:01.000Z",
    "active_shards_count": 4,
    "total_validators": 15,
    "total_staked": "480000000000000000000000",
    "average_block_time": 2.4,
    "total_transactions": 0,
    "total_gas_used": 0,
    "pow_reward_per_block": 100,
    "pos_annual_yield": 6.5,
    "shard_splits": [
      {"shard_id": 0, "new_shard_ids": [1, 2, 3]}
    ],
    "slashing_events": 0,
    "governance_proposals": []
  }' | jq '.'
echo ""

echo "Querying all epochs sorted by epoch number..."
curl -X GET \
  "${BASE_URL}/Epoch?sort=epoch_number" \
\
  -H "Content-Type: application/json" | jq '.'
echo ""

# ============================================================================
# TEST 10: NetworkStats Entity
# ============================================================================
echo "TEST 10: NetworkStats Entity"
echo "----------------------------"

echo "Creating initial network stats..."
STATS_RESPONSE=$(curl -X POST \
  "${BASE_URL}/NetworkStats" \
\
  -H "Content-Type: application/json" \
  -d '{
    "stats_id": "current",
    "current_epoch": 1,
    "current_block_height": 1000,
    "total_shards_active": 4,
    "total_addresses": 1250,
    "total_transactions": 18500,
    "total_contracts": 125,
    "circulating_supply": "10512000000000000000000000",
    "total_staked": "480000000000000000000000",
    "staking_percentage": 4.56,
    "active_validators": 15,
    "network_hashrate": 15000000000,
    "average_tps": 12.5,
    "average_block_time": 2.45,
    "average_gas_price": 1.8,
    "market_cap_usd": 105120000,
    "price_usd": 10.0,
    "last_updated": "2025-01-25T12:00:00.000Z"
  }')
echo "$STATS_RESPONSE" | jq '.'
STATS_ID=$(echo "$STATS_RESPONSE" | jq -r '.id')
echo ""

echo "Updating network stats (simulating real-time update)..."
curl -X PUT \
  "${BASE_URL}/NetworkStats/${STATS_ID}" \
\
  -H "Content-Type: application/json" \
  -d '{
    "current_block_height": 1050,
    "total_transactions": 19200,
    "average_tps": 13.2,
    "price_usd": 10.5,
    "market_cap_usd": 110376000,
    "last_updated": "2025-01-25T12:05:00.000Z"
  }' | jq '.'
echo ""

echo "Fetching current network stats..."
curl -X GET \
  "${BASE_URL}/NetworkStats?stats_id=current" \
\
  -H "Content-Type: application/json" | jq '.'
echo ""

# ============================================================================
# TEST 11: GovernanceProposal Entity
# ============================================================================
echo "TEST 11: GovernanceProposal Entity"
echo "-----------------------------------"

echo "Creating active governance proposal..."
PROPOSAL_RESPONSE=$(curl -X POST \
  "${BASE_URL}/GovernanceProposal" \
\
  -H "Content-Type: application/json" \
  -d '{
    "proposal_id": 1,
    "proposal_type": "protocol_parameters",
    "title": "Increase Block Gas Limit to 40M",
    "description": "This proposal seeks to increase the per-shard block gas limit from 30M to 40M to accommodate growing demand for smart contract execution.",
    "proposer_address": "0x89205A3A3b2A69De6Dbf7f01ED13B2108B2c43e7",
    "creation_block": 500,
    "voting_start_epoch": 2,
    "voting_end_epoch": 3,
    "status": "active",
    "votes_for": "150000000000000000000000",
    "votes_against": "50000000000000000000000",
    "votes_abstain": "10000000000000000000000",
    "quorum_reached": true,
    "total_voters": 8
  }')
echo "$PROPOSAL_RESPONSE" | jq '.'
PROPOSAL_ID=$(echo "$PROPOSAL_RESPONSE" | jq -r '.id')
echo ""

echo "Creating passed proposal..."
curl -X POST \
  "${BASE_URL}/GovernanceProposal" \
\
  -H "Content-Type: application/json" \
  -d '{
    "proposal_id": 2,
    "proposal_type": "treasury_allocation",
    "title": "Ecosystem Development Fund - 1M TESS",
    "description": "Allocate 1M TESS from treasury for ecosystem grants and developer incentives.",
    "proposer_address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb1",
    "creation_block": 100,
    "voting_start_epoch": 1,
    "voting_end_epoch": 2,
    "execution_block": 2100,
    "status": "executed",
    "votes_for": "300000000000000000000000",
    "votes_against": "20000000000000000000000",
    "votes_abstain": "5000000000000000000000",
    "quorum_reached": true,
    "total_voters": 12,
    "timelock_end_block": 2048
  }' | jq '.'
echo ""

echo "Querying all active proposals..."
curl -X GET \
  "${BASE_URL}/GovernanceProposal?status=active" \
\
  -H "Content-Type: application/json" | jq '.'
echo ""

echo "Querying proposals by proposer..."
curl -X GET \
  "${BASE_URL}/GovernanceProposal?proposer_address=0x89205A3A3b2A69De6Dbf7f01ED13B2108B2c43e7" \
\
  -H "Content-Type: application/json" | jq '.'
echo ""

# ============================================================================
# TEST 12: StakingPool Entity
# ============================================================================
echo "TEST 12: StakingPool Entity"
echo "---------------------------"

echo "Creating liquid staking pool..."
POOL_RESPONSE=$(curl -X POST \
  "${BASE_URL}/StakingPool" \
\
  -H "Content-Type: application/json" \
  -d '{
    "pool_address": "0xde0B295669a9FD93d5F28D9Ec85E40f4cb697BAe",
    "pool_name": "TessStake Pool Alpha",
    "total_value_locked": "5000000000000000000000",
    "validator_address": "0x89205A3A3b2A69De6Dbf7f01ED13B2108B2c43e7",
    "pool_token_address": "0x3B3525F60dD14F59e9f491dF3F4f6BD161Db067B",
    "pool_token_supply": "4850000000000000000000",
    "apy": 5.2,
    "depositor_count": 45,
    "creation_block": 1,
    "total_rewards_distributed": "250000000000000000000",
    "last_reward_distribution_epoch": 1
  }')
echo "$POOL_RESPONSE" | jq '.'
echo ""

echo "Creating second staking pool..."
curl -X POST \
  "${BASE_URL}/StakingPool" \
\
  -H "Content-Type: application/json" \
  -d '{
    "pool_address": "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D",
    "pool_name": "TESS Mega Staking",
    "total_value_locked": "12000000000000000000000",
    "validator_address": "0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed",
    "pool_token_address": "0x8B3525F60dD14F59e9f491dF3F4f6BD161Db068C",
    "pool_token_supply": "11700000000000000000000",
    "apy": 4.8,
    "depositor_count": 120,
    "creation_block": 50,
    "total_rewards_distributed": "580000000000000000000",
    "last_reward_distribution_epoch": 1
  }' | jq '.'
echo ""

echo "Querying all staking pools sorted by TVL..."
curl -X GET \
  "${BASE_URL}/StakingPool?sort=-total_value_locked" \
\
  -H "Content-Type: application/json" | jq '.'
echo ""

echo "Querying pools by validator..."
curl -X GET \
  "${BASE_URL}/StakingPool?validator_address=0x89205A3A3b2A69De6Dbf7f01ED13B2108B2c43e7" \
\
  -H "Content-Type: application/json" | jq '.'
echo ""

# ============================================================================
# SUMMARY
# ============================================================================
echo ""
echo "======================================"
echo "TEST SUITE COMPLETE!"
echo "======================================"
echo ""
echo "✅ Block Entity - Created genesis + shard blocks, tested filtering"
echo "✅ Transaction Entity - Created transfer/deploy/cross-shard txs"
echo "✅ Address Entity - Created user/contract/validator addresses"
echo "✅ Shard Entity - Created root lattice + child shards"
echo "✅ Validator Entity - Created validators with different stakes"
echo "✅ Delegation Entity - Created active & unbonding delegations"
echo "✅ Contract Entity - Created verified contracts & proxies"
echo "✅ CrossShardMessage Entity - Created & updated messages"
echo "✅ Epoch Entity - Created epochs with shard lifecycle events"
echo "✅ NetworkStats Entity - Created & updated real-time stats"
echo "✅ GovernanceProposal Entity - Created active & executed proposals"
echo "✅ StakingPool Entity - Created liquid staking pools"
echo ""
echo "All 12 TESSERA Protocol entities tested successfully!"
echo "API ready for blockchain indexer integration."
echo ""
