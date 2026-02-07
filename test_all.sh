#!/bin/bash

# A script to test all major functions of the Tessera node
# 1. Generate 2 accounts
# 2. Fund one account from the treasury
# 3. Transfer funds between accounts using a signed transaction
# 4. Stake funds from an account
# 5. Claim staking rewards

# Make sure to run the gateway, proxy, and cloudflared tunnel first!
# Example:
# node bin/gateway.js &
# node tessera-proxy/index.js &
# ./cloudflared-linux-amd64 tunnel --url http://localhost:8080 &

GATEWAY_URL="http://localhost:3000"
TREASURY_ADDR="0xTesseraTreasury"

echo "======= TESSERA COMPREHENSIVE TEST ======="
echo ""

# Ensure a clean state and initialize treasury
echo "--- Initializing clean state and Treasury ---"
bash bin/reset.sh
node bin/genesis-init.js
echo ""
sleep 3 # Give systems time to settle

# 1. Generate Accounts
echo "--- 1. Generating SENDER and RECEIVER accounts ---"
node bin/keygen.js > sender.json
node bin/keygen.js > receiver.json

SENDER_ADDR=$(grep "PUBLIC ADDRESS:" sender.json | awk '{print $3}')
SENDER_PRIV_KEY=$(grep "PRIVATE KEY:" sender.json | awk '{print $3}')
RECEIVER_ADDR=$(grep "PUBLIC ADDRESS:" receiver.json | awk '{print $3}')

echo "  > SENDER: $SENDER_ADDR"
echo "  > RECEIVER: $RECEIVER_ADDR"
echo ""

# 2. Fund Sender Account
echo "--- 2. Funding SENDER account with 1000 TES from Treasury ---"
bash bin/transfer.sh $SENDER_ADDR 1000
echo ""
sleep 1 # Give gateway a moment

# 3. Check Initial Balances
echo "--- 3. Checking initial balances ---"
SENDER_BALANCE_PRE=$(curl -s "$GATEWAY_URL/Account/$SENDER_ADDR" | jq -r '.balance')
RECEIVER_BALANCE_PRE=$(curl -s "$GATEWAY_URL/Account/$RECEIVER_ADDR" | jq -r '.balance // 0')
echo "  > SENDER Balance: $SENDER_BALANCE_PRE TES"
echo "  > RECEIVER Balance: $RECEIVER_BALANCE_PRE TES"
echo ""

# 4. Sign and Send Transfer
echo "--- 4. Transferring 100 TES from SENDER to RECEIVER ---"
node bin/sign-transfer.js $SENDER_ADDR $RECEIVER_ADDR 100 $SENDER_PRIV_KEY
echo ""
sleep 1

# 5. Check Post-Transfer Balances
echo "--- 5. Checking post-transfer balances ---"
SENDER_BALANCE_POST=$(curl -s "$GATEWAY_URL/Account/$SENDER_ADDR" | jq -r '.balance')
RECEIVER_BALANCE_POST=$(curl -s "$GATEWAY_URL/Account/$RECEIVER_ADDR" | jq -r '.balance')
echo "  > SENDER Balance: $SENDER_BALANCE_POST TES"
echo "  > RECEIVER Balance: $RECEIVER_BALANCE_POST TES"
echo ""

# 6. Stake Funds
echo "--- 6. Staking 50 TES from SENDER account ---"
node bin/staking.js stake $SENDER_ADDR 50
echo ""
sleep 1

# 7. Check Staking Stats
echo "--- 7. Checking staking stats ---"
node bin/staking.js stats $SENDER_ADDR
echo ""
sleep 1

# 8. Wait for Rewards
echo "--- 8. Waiting 5 seconds to accrue staking rewards ---"
sleep 5
echo ""

# 9. Claim Rewards
echo "--- 9. Claiming staking rewards for SENDER ---"
node bin/staking.js claim $SENDER_ADDR
echo ""
sleep 1

# 10. Check Final Balance
echo "--- 10. Checking final balance of SENDER ---"
SENDER_BALANCE_FINAL=$(curl -s "$GATEWAY_URL/Account/$SENDER_ADDR" | jq -r '.balance')
echo "  > SENDER Final Balance: $SENDER_BALANCE_FINAL TES"
echo ""

# 11. Cleanup
echo "--- 11. Cleaning up generated key files ---"
rm sender.json receiver.json
echo "  > Deleted sender.json and receiver.json"
echo ""

echo "======= TEST COMPLETE ======="

