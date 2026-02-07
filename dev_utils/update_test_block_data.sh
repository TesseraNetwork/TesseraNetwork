# Generate a real random 32-byte hex string
REAL_HEX="0x$(openssl rand -hex 32)"

curl -s -X PUT "https://app.base44.com/api/apps/6984c2570cad7b023d66ae06/entities/Block/69853e11bb21772e4bee8b33" \
     -H "api_key: YOUR_BASE44_KEY_PLACEHOLDER" \
     -H "Content-Type: application/json" \
     -d "{
           \"block_hash\": \"$REAL_HEX\",
           \"parent_hash\": \"0x$(openssl rand -hex 32)\",
           \"state_root\": \"0x$(openssl rand -hex 32)\"
         }" | jq
