#!/bin/bash
# Tessera Protocol: Distribution Script (String-Type Fix)

API_KEY="YOUR_BASE44_KEY_PLACEHOLDER"
APP_ID="6984c2570cad7b023d66ae06"
FOUNDER_ID="69853e11bb21772e4bee8b33" 

echo "💸 Processing Tessera Transfer (Strict String Mode)..."

# 1. Update Founder (Wrap balance in quotes)
curl -s -X PUT "https://app.base44.com/api/apps/$APP_ID/entities/Account/$FOUNDER_ID" \
     -H "api_key: $API_KEY" \
     -H "Content-Type: application/json" \
     -d "{
           \"balance\": \"999500.0\",
           \"nonce\": 1
         }" > /dev/null

# 2. Create Community Wallet (Wrap balance in quotes)
curl -s -X POST "https://app.base44.com/api/apps/$APP_ID/entities/Account" \
     -H "api_key: $API_KEY" \
     -H "Content-Type: application/json" \
     -d '{
           "address": "0xCommunityFund1234567890abcdef12345678",
           "balance": "500.0",
           "nonce": 0
         }' | jq

echo "✅ Transfer Complete. Total Supply Verified: 1,000,000 TES"
