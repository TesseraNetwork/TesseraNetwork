#!/bin/bash
# API_KEY is now handled by the proxy server
BASE_URL="http://localhost:3000/api/tessera"

echo "🟢 TESSERA Blockchain Monitor - $(date)"
echo "========================================"

# Health checks
echo "1. Network Status:"
curl -s "$BASE_URL/NetworkStats"| python3 -c "
import sys,json,socket,datetime
data=json.load(sys.stdin)[0]
print(f'   Block Height: {data[\"current_block_height\"]:,}')
print(f'   TPS: {data[\"average_tps\"]}')
print(f'   Active Shards: {data[\"total_shards_active\"]}')
print(f'   Price: \${data[\"price_usd\"]}')
print(f'   Last Updated: {data[\"last_updated\"]}')
"

echo -e "\n2. Block Production (last 5 blocks):"
curl -s "$BASE_URL/Block?limit=5&sort=-block_number"| python3 -c "
import sys,json
data=json.load(sys.stdin)
for block in data:
    age = (20040 - block['block_number']) * 2.45  # Approx seconds
    print(f'   Block {int(block[\"block_number\"]):,} (Shard {int(block[\"shard_id\"]):,}): {block[\"transaction_count\"]} tx, {age:.0f}s ago')
"

echo -e "\n3. System Alerts:"
# Check for critical conditions
curl -s "$BASE_URL/CrossShardMessage?status=initiated"| python3 -c "
import sys,json
data=json.load(sys.stdin)
if len(data) > 10:
    print('   ⚠️  High pending cross-shard messages:', len(data))
else:
    print('   ✅ Normal cross-shard queue')
"

curl -s "$BASE_URL/Validator?uptime_percentage__lt=95"| python3 -c "
import sys,json
data=json.load(sys.stdin)
if data:
    print('   ⚠️  Low uptime validators:', len(data))
else:
    print('   ✅ All validators >95% uptime')
"
