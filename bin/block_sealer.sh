#!/bin/bash

GATEWAY="http://localhost:3000"

echo "🛠️  TESSERA PROTOCOL: MINTING BLOCK #1..."
echo "---------------------------------------"

# 1. Fetch current Hot State for the "Snapshot"
TREASURY_BAL=$(curl -s "$GATEWAY/Account/0xTesseraTreasury" | jq -r '.balance')
LUCIEL_BAL=$(curl -s "$GATEWAY/Account/0xLuciel" | jq -r '.balance')

# 2. Generate a Pseudo-Hash (Combining the balances)
TIMESTAMP=$(date +%s)
BLOCK_HASH=$(echo -n "block-1-$TIMESTAMP-$TREASURY_BAL-$LUCIEL_BAL" | sha256sum | awk '{print "0x"$1}')

echo "📦 State Snapshot captured."
echo "🔗 Hash: $BLOCK_HASH"

# 3. Post the Block to the Ledger with ALL required fields
curl -s -X POST "$GATEWAY/Block" \
     -H "Content-Type: application/json" \
     -d "{
           \"block_hash\": \"$BLOCK_HASH\",
           \"block_number\": 1,
           \"shard_id\": 0,
           \"epoch\": 1,
           \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
           \"miner_address\": \"0xTermuxMiner\",
           \"parent_hash\": \"0x0000000000000000000000000000000000000000000000000000000000000000\",
           \"difficulty\": 1,
           \"nonce\": \"$TIMESTAMP\",
           \"state_root\": \"$BLOCK_HASH\",
           \"transactions_root\": \"0x0\",
           \"receipts_root\": \"0x0\",
           \"gas_used\": 0,
           \"gas_limit\": 30000000,
           \"base_fee\": 0,
           \"block_reward\": 0,
           \"transaction_count\": 1,
           \"finality_status\": \"finalized\"
         }" | jq

echo -e "\n✅ BLOCK #1 SEALED."
