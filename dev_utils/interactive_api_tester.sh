#!/bin/bash

# Base configuration
# API_KEY is now handled by the proxy server
BASE_URL="http://localhost:3000/api/tessera"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper function to make API calls
api_call() {
    local method="$1"
    local endpoint="$2"
    local data="$3"
    
    echo -e "${BLUE}Making $method request to $endpoint${NC}"
    
    if [ -n "$data" ]; then
        curl -X "$method" \
            "$BASE_URL/$endpoint" \

            -H "Content-Type: application/json" \
            -d "$data" 2>/dev/null | python3 -m json.tool
    else
        curl -X "$method" \
            "$BASE_URL/$endpoint" \

            -H "Content-Type: application/json" 2>/dev/null | python3 -m json.tool
    fi
    
    echo ""
}

# Test 1: Fix the CrossShardMessage merkle_proof issue
fix_merkle_proof() {
    echo -e "${YELLOW}=== Test 1: Fix CrossShardMessage merkle_proof ===${NC}"
    
    # First, let's see the current state
    echo -e "${BLUE}Getting current CrossShardMessage...${NC}"
    api_call "GET" "CrossShardMessage/6984c4dc31f160ae08a9a823"
    
    # Now fix it with proper list format
    echo -e "${BLUE}Updating with correct merkle_proof format...${NC}"
    api_call "PUT" "CrossShardMessage/6984c4dc31f160ae08a9a823" \
        '{
            "status": "committed",
            "merkle_proof": ["0xabc", "0xdef", "0x123", "0x456"],
            "commitment_block": 55,
            "total_latency_blocks": 10
        }'
}

# Test 2: Create a complex cross-shard transaction
create_cross_shard_transaction() {
    echo -e "${YELLOW}=== Test 2: Create Complex Cross-Shard Transaction ===${NC}"
    
    # Generate random transaction hash
    TX_HASH="0x$(openssl rand -hex 32)"
    
    api_call "POST" "Transaction" \
        '{
            "tx_hash": "'$TX_HASH'",
            "block_hash": "0x1000000000000000000000000000000000000000000000000000000000000001",
            "block_number": 2,
            "shard_id": 1,
            "timestamp": "2025-01-15T00:05:00.000Z",
            "from_address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb1",
            "to_address": "0x89205A3A3b2A69De6Dbf7f01ED13B2108B2c43e7",
            "value": "2500000000000000000",
            "gas_price": 3.5,
            "gas_limit": 150000,
            "gas_used": 145000,
            "nonce": 3,
            "input_data": "0xa9059cbb00000000000000000000000089205a3a3b2a69de6dbf7f01ed13b2108b2c43e70000000000000000000000000000000000000000000000022b1c8c1227a00000",
            "tx_type": "cross_shard_message",
            "status": "success",
            "cross_shard_destination": 3,
            "cross_shard_status": "initiated"
        }'
}

# Test 3: Test complex queries with filters
test_complex_queries() {
    echo -e "${YELLOW}=== Test 3: Complex Query Filters ===${NC}"
    
    echo -e "${BLUE}Query 1: Transactions from specific address with gas price range${NC}"
    curl -s "$BASE_URL/Transaction?from_address=0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb1&gas_price__gte=1&gas_price__lte=5&limit=5" \
| python3 -m json.tool
    
    echo -e "${BLUE}Query 2: Blocks in shard 1 with transaction count > 0${NC}"
    curl -s "$BASE_URL/Block?shard_id=1&transaction_count__gt=0&limit=5" \
| python3 -m json.tool
    
    echo -e "${BLUE}Query 3: Validators with high uptime and stakes${NC}"
    curl -s "$BASE_URL/Validator?uptime_percentage__gte=95&total_stake__gte=10000000000000000000000&limit=5" \
| python3 -m json.tool
}

# Test 4: Create a governance proposal
create_governance_proposal() {
    echo -e "${YELLOW}=== Test 4: Create Governance Proposal ===${NC}"
    
    api_call "POST" "GovernanceProposal" \
        '{
            "proposal_id": 3,
            "proposal_type": "shard_split",
            "title": "Split Shard 1 into Shards 101 and 102",
            "description": "Due to increased transaction volume in shard 1, propose splitting it into two separate shards to improve throughput and reduce gas fees.",
            "proposer_address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb1",
            "creation_block": 1500,
            "voting_start_epoch": 3,
            "voting_end_epoch": 4,
            "status": "pending",
            "execution_payload": {
                "shard_to_split": 1,
                "new_shard_ids": [101, 102],
                "state_distribution_strategy": "address_hash_modulo",
                "validator_reassignment": "randomized",
                "execution_block": 2016
            }
        }'
}

# Test 5: Update network stats
update_network_stats() {
    echo -e "${YELLOW}=== Test 5: Update Network Stats ===${NC}"
    
    # First get current stats
    echo -e "${BLUE}Current network stats:${NC}"
    api_call "GET" "NetworkStats/6984c4dfc17482f8734b6d97"
    
    # Update with new data
    echo -e "${BLUE}Updating network stats...${NC}"
    api_call "PUT" "NetworkStats/6984c4dfc17482f8734b6d97" \
        '{
            "current_block_height": 1100,
            "total_transactions": 21000,
            "average_tps": 15.8,
            "price_usd": 12.75,
            "market_cap_usd": 134100000,
            "last_updated": "2025-01-25T12:30:00.000Z"
        }'
}

# Test 6: Create a new shard
create_new_shard() {
    echo -e "${YELLOW}=== Test 6: Create New Shard ===${NC}"
    
    api_call "POST" "Shard" \
        '{
            "shard_id": 101,
            "parent_shard_id": 1,
            "creation_epoch": 3,
            "current_status": "active",
            "current_block_height": 0,
            "total_transactions": 0,
            "active_validators": [
                "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb1",
                "0x89205A3A3b2A69De6Dbf7f01ED13B2108B2c43e7"
            ],
            "validator_rotation_epoch": 4,
            "cumulative_gas_used": 0,
            "average_block_time": 2.3,
            "child_shard_ids": [],
            "merge_target_shard_id": null,
            "last_checkpoint_block": null,
            "state_size_gb": 0.1
        }'
}

# Test 7: Test error handling
test_error_handling() {
    echo -e "${YELLOW}=== Test 7: Error Handling ===${NC}"
    
    echo -e "${BLUE}Test 1: Malformed transaction (invalid address)${NC}"
    api_call "POST" "Transaction" \
        '{
            "tx_hash": "not_a_hex",
            "from_address": "invalid_address",
            "value": "not_a_number"
        }'
    
    echo -e "${BLUE}Test 2: Duplicate block hash${NC}"
    api_call "POST" "Block" \
        '{
            "block_hash": "0x0000000000000000000000000000000000000000000000000000000000000001",
            "block_number": 0,
            "shard_id": 0
        }'
    
    echo -e "${BLUE}Test 3: Non-existent entity${NC}"
    curl -s "$BASE_URL/Block/nonexistent_id_123" \
| python3 -m json.tool
}

# Test 8: Create batch of transactions
create_batch_transactions() {
    echo -e "${YELLOW}=== Test 8: Batch Transaction Creation ===${NC}"
    
    for i in {1..5}; do
        echo -e "${BLUE}Creating transaction $i...${NC}"
        TX_HASH="0x$(openssl rand -hex 32)"
        api_call "POST" "Transaction" \
            '{
                "tx_hash": "'$TX_HASH'",
                "block_hash": "0x1000000000000000000000000000000000000000000000000000000000000001",
                "block_number": '$((100 + i))',
                "shard_id": '$((i % 3))',
                "timestamp": "2025-01-15T00:$((i)):00.000Z",
                "from_address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb1",
                "to_address": "0x89205A3A3b2A69De6Dbf7f01ED13B2108B2c43e7",
                "value": "'$((RANDOM * 1000000000000000))'",
                "gas_price": '$((RANDOM % 5 + 1)).$((RANDOM % 99))',
                "gas_limit": '$((RANDOM % 1000000 + 21000))',
                "gas_used": '$((RANDOM % 1000000 + 21000))',
                "nonce": '$i',
                "tx_type": "transfer",
                "status": "success"
            }'
        sleep 0.5 # Small delay to avoid rate limiting
    done
}

# Test 9: Test pagination and sorting
test_pagination_sorting() {
    echo -e "${YELLOW}=== Test 9: Pagination and Sorting ===${NC}"
    
    echo -e "${BLUE}Blocks sorted by block_number (descending), page 1, 3 per page${NC}"
    curl -s "$BASE_URL/Block?limit=3&skip=0&sort=-block_number" \
| python3 -m json.tool
    
    echo -e "${BLUE}Addresses sorted by balance (descending) - rich list${NC}"
    curl -s "$BASE_URL/Address?limit=5&sort=-balance" \
| python3 -m json.tool
    
    echo -e "${BLUE}Validators sorted by total_stake (descending)${NC}"
    curl -s "$BASE_URL/Validator?limit=5&sort=-total_stake" \
| python3 -m json.tool
}

# Test 10: Update cross-shard message lifecycle
test_cross_shard_lifecycle() {
    echo -e "${YELLOW}=== Test 10: Cross-Shard Message Lifecycle ===${NC}"
    
    # Create a new cross-shard message
    echo -e "${BLUE}Creating new cross-shard message...${NC}"
    MSG_ID="msg_$(date +%s)_$RANDOM"
    TX_HASH="0x$(openssl rand -hex 32)"
    
    CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL/CrossShardMessage" \
\
        -H "Content-Type: application/json" \
        -d '{
            "message_id": "'$MSG_ID'",
            "initiating_tx_hash": "'$TX_HASH'",
            "source_shard_id": 1,
            "destination_shard_id": 2,
            "source_block": 100,
            "sender_address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb1",
            "recipient_address": "0x89205A3A3b2A69De6Dbf7f01ED13B2108B2c43e7",
            "value": "1000000000000000000",
            "gas_limit": 100000,
            "message_data": "0x",
            "status": "initiated"
        }')
    
    echo "$CREATE_RESPONSE" | python3 -m json.tool
    
    # Extract the ID from response
    NEW_ID=$(echo "$CREATE_RESPONSE" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
    
    if [ -n "$NEW_ID" ]; then
        echo -e "${GREEN}Created message with ID: $NEW_ID${NC}"
        
        # Update to committed
        echo -e "${BLUE}Updating to committed status...${NC}"
        api_call "PUT" "CrossShardMessage/$NEW_ID" \
            '{
                "status": "committed",
                "merkle_proof": ["0xabc123", "0xdef456", "0x789012"],
                "commitment_block": 110
            }'
        
        # Update to executed
        echo -e "${BLUE}Updating to executed status...${NC}"
        api_call "PUT" "CrossShardMessage/$NEW_ID" \
            '{
                "status": "executed",
                "execution_tx_hash": "0x'$(openssl rand -hex 32)'",
                "execution_block": 115,
                "total_latency_blocks": 15
            }'
    fi
}

# Main menu
main() {
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}   TESSERA BLOCKCHAIN API TESTER      ${NC}"
    echo -e "${GREEN}========================================${NC}"
    
    while true; do
        echo ""
        echo "Select a test to run:"
        echo "1. Fix merkle_proof bug"
        echo "2. Create cross-shard transaction"
        echo "3. Test complex queries"
        echo "4. Create governance proposal"
        echo "5. Update network stats"
        echo "6. Create new shard"
        echo "7. Test error handling"
        echo "8. Create batch transactions"
        echo "9. Test pagination/sorting"
        echo "10. Test cross-shard lifecycle"
        echo "0. Run all tests"
        echo "q. Quit"
        echo ""
        read -p "Enter choice: " choice
        
        case $choice in
            1) fix_merkle_proof ;;
            2) create_cross_shard_transaction ;;
            3) test_complex_queries ;;
            4) create_governance_proposal ;;
            5) update_network_stats ;;
            6) create_new_shard ;;
            7) test_error_handling ;;
            8) create_batch_transactions ;;
            9) test_pagination_sorting ;;
            10) test_cross_shard_lifecycle ;;
            0)
                fix_merkle_proof
                create_cross_shard_transaction
                test_complex_queries
                create_governance_proposal
                update_network_stats
                create_new_shard
                test_error_handling
                create_batch_transactions
                test_pagination_sorting
                test_cross_shard_lifecycle
                ;;
            q|Q) exit 0 ;;
            *) echo "Invalid choice" ;;
        esac
    done
}

# Run main menu
main
