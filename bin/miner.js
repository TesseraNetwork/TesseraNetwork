const axios = require('axios');

const CONFIG = {
    GATEWAY: "http://localhost:3000",
    TICK_RATE: 30000,
    LAST_BLOCK: 3 // Update this to your current block height
};

// Add your new address here to track it in the console!
const WATCHLIST = [
    "0xTesseraTreasury",
    "0xLuciel",
    "0x77144F39CFF1C5E5F0BC253D13DD292F7527E995"
];

async function mine() {
    console.log(`\n⛏️  FOUNDER NODE: scanning state...`);
    
    let snapshot = "";
    for (const addr of WATCHLIST) {
        try {
            const res = await axios.get(`${CONFIG.GATEWAY}/Account/${addr}`);
            snapshot += `${addr.substring(0,6)}: ${res.data.balance} | `;
        } catch (e) {}
    }
    
    console.log(`📊 Snapshot: ${snapshot}`);

    const nextBlock = CONFIG.LAST_BLOCK + 1;
    const timestamp = Math.floor(Date.now() / 1000);
    const blockHash = "0x" + Buffer.from(`block-${nextBlock}-${timestamp}`).toString('hex').substring(0, 64);

    try {
        await axios.post(`${CONFIG.GATEWAY}/Block`, {
            block_hash: blockHash,
            block_number: nextBlock,
            shard_id: 0,
            epoch: 1,
            timestamp: new Date().toISOString(),
            miner_address: "0xFounderNode_01",
            parent_hash: "0x0000000000000000000000000000000000000000000000000000000000000000",
            difficulty: 1,
            nonce: timestamp.toString(),
            state_root: blockHash,
            transactions_root: "0x0",
            receipts_root: "0x0",
            gas_used: 0,
            gas_limit: 30000000,
            base_fee: 0,
            block_reward: 0,
            transaction_count: 1,
            finality_status: "finalized"
        });
        console.log(`✅ BLOCK #${nextBlock} SEALED.`);
        CONFIG.LAST_BLOCK = nextBlock;
    } catch (err) {
        console.error("❌ Mining Error");
    }
}

setInterval(mine, CONFIG.TICK_RATE);
mine();

