#!/bin/bash

GATEWAY="http://localhost:3000"

echo "📡 TESSERA PULSE: REAL-TIME STATE MONITOR"
echo "------------------------------------------"
echo "ADDRESS                                      | BALANCE    | SOURCE"
echo "---------------------------------------------------------------------"

# Get all accounts from the gateway
ALL_ACCOUNTS=$(curl -s "$GATEWAY/Account")

# Extract unique addresses (Base44 might return duplicates from old records)
ADDRESSES=$(echo "$ALL_ACCOUNTS" | jq -r '.[].address' | sort -u)

TOTAL_SUPPLY=0

for ADDR in $ADDRESSES; do
    DATA=$(curl -s "$GATEWAY/Account/$ADDR")
    BAL=$(echo $DATA | jq -r '.balance // "0.0"')
    SRC=$(echo $DATA | jq -r '.source // "📜 COLD_LEDGER"')

    # Add to total supply
    TOTAL_SUPPLY=$(echo "$TOTAL_SUPPLY + $BAL" | bc -l)

    # Format the address for display
    if [[ ${#ADDR} -gt 20 ]]; then
        # Shorten long addresses: 0xABCD...WXYZ
        DISPLAY_ADDR="${ADDR:0:10}...${ADDR: -8}"
    else
        DISPLAY_ADDR="$ADDR"
    fi

    # Simple formatting
    printf "%-44s | %-10s | %s\n" "$DISPLAY_ADDR" "$BAL" "$SRC"
done

echo "---------------------------------------------------------------------"
printf "Total Network Supply: %.1f TES\n" $TOTAL_SUPPLY
