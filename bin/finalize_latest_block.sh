#!/bin/bash

APP_ID="6984c2570cad7b023d66ae06"
API_KEY="YOUR_BASE44_KEY_PLACEHOLDER"
BASE_URL="https://app.base44.com/api/apps/$APP_ID/entities/Block"

echo "🚀 Tessera Protocol: Starting Auto-Finality Job..."

# 1. Get the ID of the most recently created block
TARGET_ID=$(curl -s -X GET "$BASE_URL" \
     -H "api_key: $API_KEY" \
     -H "Content-Type: application/json" | jq -r '.[0].id')

if [ "$TARGET_ID" == "null" ] || [ -z "$TARGET_ID" ]; then
    echo "❌ Error: No blocks found."
    exit 1
fi

echo "✅ Found Block ID: $TARGET_ID"

# 2. Update that block to 'finalized'
echo "🛠 Finalizing block..."
curl -s -X PUT "$BASE_URL/$TARGET_ID" \
     -H "api_key: $API_KEY" \
     -H "Content-Type: application/json" \
     -d '{
           "finality_status": "finalized",
           "updated_date": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"
         }' | jq -r '.message // "Update successful"'

echo "🏁 Job Complete."
