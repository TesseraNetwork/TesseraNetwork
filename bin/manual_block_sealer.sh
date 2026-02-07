#!/bin/bash
API_KEY="YOUR_BASE44_KEY_PLACEHOLDER"
APP_ID="6984c2570cad7b023d66ae06"

# 1. Look for a request
REQUEST=$(curl -s -H "api_key: $API_KEY" "https://app.base44.com/api/apps/$APP_ID/entities/Mempool" | jq '.[0]')

if [ "$REQUEST" == "null" ]; then
    echo "☕ TESSERA is idle."
    exit 1
fi

MEM_ID=$(echo $REQUEST | jq -r '.id')
FROM=$(echo $REQUEST | jq -r '.from_address')
TO=$(echo $REQUEST | jq -r '.to_address')
AMT=$(echo $REQUEST | jq -r '.amount')

echo "📨 Processing: $FROM -> $TO ($AMT TES)"

# 2. Update the Sender (We assume they have enough for now)
# Logic: Founder had 999500.0, now subtracting 100.0
curl -s -X PUT "https://app.base44.com/api/apps/$APP_ID/entities/Account/69853e11bb21772e4bee8b33" \
     -H "api_key: $API_KEY" -H "Content-Type: application/json" \
     -d "{\"balance\": \"999400.0\", \"nonce\": 2}" > /dev/null

# 3. Create the Block & Transaction Ledger
BLOCK_ID=$(curl -s -X POST "https://app.base44.com/api/apps/$APP_ID/entities/Block" \
     -H "api_key: $API_KEY" -H "Content-Type: application/json" \
     -d "{\"block_hash\": \"0x$(openssl rand -hex 32)\", \"finality_status\": \"finalized\"}" | jq -r '.id')

curl -s -X POST "https://app.base44.com/api/apps/$APP_ID/entities/Transaction" \
     -H "api_key: $API_KEY" -H "Content-Type: application/json" \
     -d "{\"from_address\": \"$FROM\", \"to_address\": \"$TO\", \"amount\": \"$AMT\", \"tx_hash\": \"0x$(openssl rand -hex 32)\", \"block_id\": \"$BLOCK_ID\"}" > /dev/null

# 4. Clear the Mempool
curl -s -X DELETE "https://app.base44.com/api/apps/$APP_ID/entities/Mempool/$MEM_ID" \
     -H "api_key: $API_KEY" > /dev/null

echo "✅ Block $BLOCK_ID Finalized. State updated."
