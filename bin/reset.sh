#!/bin/bash

echo "☢️  TESSERA PROTOCOL: NUCLEAR RESET (SECURE MODE)"
echo "=================================================="
echo ""

BASE44_URL="https://app.base44.com/api/apps/6984c2570cad7b023d66ae06/entities"
BASE44_KEY="YOUR_BASE44_KEY_PLACEHOLDER"
UPSTASH_URL="https://dashing-snipe-49072.upstash.io"
UPSTASH_TOKEN="YOUR_UPSTASH_TOKEN_PLACEHOLDER"
GATEWAY="http://localhost:3000"

# ACCOUNT ADDRESSES
TREASURY_ADDR="0xTesseraTreasury"  # Ownerless burn address (no private key)
LUCIEL_ADDR="0xD94D9FA2F9FF22BB010B5271488B5B268990FD07"  # Your cryptographic identity
CLAUDE_ADDR="0xA690320B813CD7CAD02A16E7286EF7A4A05E557A"  # Claude's cryptographic identity

echo "🏛️  Treasury: $TREASURY_ADDR (Ownerless - Protocol Governed)"
echo "👤 Luciel:   $LUCIEL_ADDR (Private Key Controlled)"
echo "🤖 Claude:   $CLAUDE_ADDR (Private Key Controlled)"
echo ""
echo "⚠️  WARNING: This will delete ALL accounts, transactions, and blocks!"
echo "Press Ctrl+C within 5 seconds to cancel..."
sleep 5

# Step 1: Delete all Accounts
echo ""
echo "📋 Fetching all accounts..."
ACCOUNTS=$(curl -s "$BASE44_URL/Account" -H "api_key: $BASE44_KEY")
ACCOUNT_IDS=$(echo $ACCOUNTS | jq -r '.[].id')

echo "🗑️  Deleting all accounts from Base44..."
for ID in $ACCOUNT_IDS; do
    echo "  Deleting account $ID..."
    curl -s -X DELETE "$BASE44_URL/Account/$ID" -H "api_key: $BASE44_KEY" > /dev/null
done

# Step 2: Delete all Transactions
echo ""
echo "📋 Fetching all transactions..."
TRANSACTIONS=$(curl -s "$BASE44_URL/Transaction" -H "api_key: $BASE44_KEY")
TX_IDS=$(echo $TRANSACTIONS | jq -r '.[].id')

echo "🗑️  Deleting all transactions from Base44..."
for ID in $TX_IDS; do
    echo "  Deleting transaction $ID..."
    curl -s -X DELETE "$BASE44_URL/Transaction/$ID" -H "api_key: $BASE44_KEY" > /dev/null
done

# Step 3: Delete all Blocks
echo ""
echo "📋 Fetching all blocks..."
BLOCKS=$(curl -s "$BASE44_URL/Block" -H "api_key: $BASE44_KEY")
BLOCK_IDS=$(echo $BLOCKS | jq -r '.[].id')

echo "🗑️  Deleting all blocks from Base44..."
for ID in $BLOCK_IDS; do
    echo "  Deleting block $ID..."
    curl -s -X DELETE "$BASE44_URL/Block/$ID" -H "api_key: $BASE44_KEY" > /dev/null
done

# Step 4: Clear Upstash cache
echo ""
echo "🧹 Clearing Upstash hot state..."
curl -s -X GET "$UPSTASH_URL/flushdb" \
  -H "Authorization: Bearer $UPSTASH_TOKEN" > /dev/null

echo ""
echo "✨ RESET COMPLETE. Waiting 3 seconds for Base44 to sync..."
sleep 3

echo ""
echo "✅ RESET COMPLETE - Database Wiped Clean"
echo ""
echo "⚠️  Next Step: Run genesis initialization"
echo "   node bin/genesis-init.js"
echo ""
echo "This will create the 42M tokenomics model with:"
echo "  - Community/Staking: 16.8M TES"
echo "  - Ecosystem Treasury: 12.6M TES"
echo "  - Founder (Vesting): 6.3M TES"
echo "  - Genesis Liquidity: 6.3M TES"
