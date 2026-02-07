#!/bin/bash
# Tessera Protocol: Genesis Transaction Recorder

API_KEY="YOUR_BASE44_KEY_PLACEHOLDER"
APP_ID="6984c2570cad7b023d66ae06"
BLOCK_ID="69853e11bb21772e4bee8b33" # Your finalized block

echo "📝 Recording Genesis Transaction..."

TX_HASH="0x$(openssl rand -hex 32)"

curl -s -X POST "https://app.base44.com/api/apps/$APP_ID/entities/Transaction" \
     -H "api_key: $API_KEY" \
     -H "Content-Type: application/json" \
     -d "{
           \"from_address\": \"0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb1\",
           \"to_address\": \"0xCommunityFund1234567890abcdef12345678\",
           \"amount\": \"500.0\",
           \"tx_hash\": \"$TX_HASH\",
           \"block_id\": \"$BLOCK_ID\"
         }" | jq

echo "✅ Transaction $TX_HASH has been etched into Block $BLOCK_ID"
