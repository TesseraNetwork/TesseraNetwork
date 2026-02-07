#!/bin/bash

GATEWAY="http://localhost:3000"

# Check arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: bash bin/transfer.sh <to_address> <amount>"
    echo "Example: bash bin/transfer.sh 0xLuciel 500"
    exit 1
fi

TO_ADDR=$1
AMOUNT=$2
FROM_ADDR="0xTesseraTreasury"

echo "💸 TESSERA TRANSFER: $FROM_ADDR -> $TO_ADDR"
echo "------------------------------------------------"

# 1. Get FULL Sender Data (balance + nonce)
echo "🔍 Checking sender balance..."
SENDER_DATA=$(curl -s "$GATEWAY/Account/$FROM_ADDR" || echo '{}')
CURRENT_BAL=$(echo "$SENDER_DATA" | jq -r 'if .balance then .balance else "0" end')
SENDER_NONCE=$(echo "$SENDER_DATA" | jq -r 'if .nonce then .nonce else "0" end')

if (( $(echo "$CURRENT_BAL < $AMOUNT" | bc -l) )); then
    echo "❌ INSUFFICIENT FUNDS: Sender has $CURRENT_BAL TES"
    exit 1
fi

# 2. Get FULL Receiver Data
echo "🔍 Checking receiver..."
REC_DATA=$(curl -s "$GATEWAY/Account/$TO_ADDR" || echo '{}')
REC_BAL=$(echo "$REC_DATA" | jq -r 'if .balance then .balance else "0" end')
REC_NONCE=$(echo "$REC_DATA" | jq -r 'if .nonce then .nonce else "0" end')

# 3. Calculate New Balances
NEW_SENDER_BAL=$(echo "$CURRENT_BAL - $AMOUNT" | bc -l)
NEW_REC_BAL=$(echo "$REC_BAL + $AMOUNT" | bc -l)

# 4. Increment Nonces
NEW_SENDER_NONCE=$((SENDER_NONCE + 1))
NEW_REC_NONCE=$((REC_NONCE + 1))

echo "📉 Updating Sender: Balance=$NEW_SENDER_BAL, Nonce=$NEW_SENDER_NONCE..."
curl -s -X POST "$GATEWAY/Account" \
     -H "Content-Type: application/json" \
     -d "{ \"address\": \"$FROM_ADDR\", \"balance\": \"$NEW_SENDER_BAL\", \"nonce\": $NEW_SENDER_NONCE }" > /dev/null

echo "📈 Updating Receiver: Balance=$NEW_REC_BAL, Nonce=$NEW_REC_NONCE..."
curl -s -X POST "$GATEWAY/Account" \
     -H "Content-Type: application/json" \
     -d "{ \"address\": \"$TO_ADDR\", \"balance\": \"$NEW_REC_BAL\", \"nonce\": $NEW_REC_NONCE }" > /dev/null

echo -e "\n✅ TRANSFER SUCCESSFUL"
echo "💰 $AMOUNT TES moved to $TO_ADDR"
echo "⚡ Hot State + Cold Ledger synced."
