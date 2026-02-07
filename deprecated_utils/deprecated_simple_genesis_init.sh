#!/bin/bash

GATEWAY="http://localhost:3000"

echo "💎 TESSERA PROTOCOL: GENESIS INITIALIZATION"
echo "------------------------------------------"

# 1. Initialize Treasury (Already works, but good to keep)
echo "🏦 Minting Genesis Supply..."
curl -s -X POST "$GATEWAY/Account" \
     -H "Content-Type: application/json" \
     -d '{
           "address": "0xTesseraTreasury",
           "balance": "1000000.0",
           "nonce": 0
         }' | jq

# 2. Mint Block 0 (The Genesis Block)
# Including ALL 13 missing fields required by your Base44 schema
echo -e "\n📦 Sealing Genesis Block (Block #0)..."
curl -s -X POST "$GATEWAY/Block" \
     -H "Content-Type: application/json" \
     -d "{
           \"block_hash\": \"0x0000000000000000000000000000000000000000000000000000000000000000\",
           \"block_number\": 0,
           \"shard_id\": 0,
           \"epoch\": 0,
           \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
           \"miner_address\": \"0x0000000000000000000000000000000000000000\",
           \"difficulty\": 1,
           \"nonce\": \"0\",
           \"parent_hash\": \"0x0\",
           \"state_root\": \"0x0\",
           \"transactions_root\": \"0x0\",
           \"receipts_root\": \"0x0\",
           \"finality_status\": \"finalized\",
           \"gas_used\": 0,
           \"gas_limit\": 30000000,
           \"base_fee\": 0,
           \"block_reward\": 0,
           \"transaction_count\": 0
         }" | jq

echo -e "\n✅ GENESIS COMPLETE. History is sealed."


