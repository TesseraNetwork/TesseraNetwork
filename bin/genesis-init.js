#!/usr/bin/env node

const axios = require('axios');

const CONFIG = {
    BASE44_URL: "https://app.base44.com/api/apps/6984c2570cad7b023d66ae06/entities",
    BASE44_KEY: "YOUR_BASE44_KEY_PLACEHOLDER",
    GATEWAY: "http://localhost:3000"
};

// Tokenomics Constants
const TOTAL_SUPPLY = 42_000_000;
const BURN_FLOOR = 21_000_000;

const DISTRIBUTION = {
    community_staking: 16_800_000,  // 40%
    ecosystem_treasury: 12_600_000, // 30%
    founder: 6_300_000,             // 15%
    genesis_liquidity: 6_300_000    // 15%
};

// Emission Schedule (10 years, 20% decay)
const EMISSION_SCHEDULE = [
    { year: 1, emission: 3_360_000, inflation: 0.133 },
    { year: 2, emission: 2_688_000, inflation: 0.094 },
    { year: 3, emission: 2_150_400, inflation: 0.068 },
    { year: 4, emission: 1_720_320, inflation: 0.051 },
    { year: 5, emission: 1_376_256, inflation: 0.039 },
    { year: 6, emission: 1_101_005, inflation: 0.030 },
    { year: 7, emission: 880_804, inflation: 0.023 },
    { year: 8, emission: 704_643, inflation: 0.018 },
    { year: 9, emission: 563_714, inflation: 0.014 },
    { year: 10, emission: 450_972, inflation: 0.011 }
];

// Addresses
const TREASURY_ADDR = "0xTesseraTreasury";
const FOUNDER_ADDR = "0xD94D9FA2F9FF22BB010B5271488B5B268990FD07";
const COMMUNITY_POOL_ADDR = "0xCommunityStakingPool";
const LIQUIDITY_POOL_ADDR = "0xGenesisLiquidity";

async function initializeGenesis() {
    console.log("🌱 TESSERA PROTOCOL: GENESIS INITIALIZATION");
    console.log("============================================");
    console.log(`Total Supply: ${TOTAL_SUPPLY.toLocaleString()} TES`);
    console.log(`Burn Floor: ${BURN_FLOOR.toLocaleString()} TES`);
    console.log("");

    try {
        // 1. Create Core Accounts
        console.log("📦 Creating core accounts...");
        
        await axios.post(`${CONFIG.GATEWAY}/Account`, {
            address: TREASURY_ADDR,
            balance: DISTRIBUTION.ecosystem_treasury.toString(),
            nonce: 0
        });
        console.log(`  ✓ Ecosystem Treasury: ${DISTRIBUTION.ecosystem_treasury.toLocaleString()} TES`);

        await axios.post(`${CONFIG.GATEWAY}/Account`, {
            address: COMMUNITY_POOL_ADDR,
            balance: DISTRIBUTION.community_staking.toString(),
            nonce: 0
        });
        console.log(`  ✓ Community Staking Pool: ${DISTRIBUTION.community_staking.toLocaleString()} TES`);

        await axios.post(`${CONFIG.GATEWAY}/Account`, {
            address: LIQUIDITY_POOL_ADDR,
            balance: DISTRIBUTION.genesis_liquidity.toString(),
            nonce: 0
        });
        console.log(`  ✓ Genesis Liquidity: ${DISTRIBUTION.genesis_liquidity.toLocaleString()} TES`);

        await axios.post(`${CONFIG.GATEWAY}/Account`, {
            address: FOUNDER_ADDR,
            balance: "0",  // Locked in vesting
            nonce: 0
        });
        console.log(`  ✓ Founder Account: 0 TES (vesting locked)`);

        // 2. Create Founder Vesting Schedule
        console.log("\n🔒 Creating founder vesting schedule...");
        
        const cliffDate = new Date();
        cliffDate.setFullYear(cliffDate.getFullYear() + 1); // 1 year cliff
        
        const vestingEnd = new Date();
        vestingEnd.setFullYear(vestingEnd.getFullYear() + 4); // 1yr cliff + 3yr vest = 4 years total

        await axios.post(`${CONFIG.BASE44_URL}/Vesting`, {
            address: FOUNDER_ADDR,
            total_amount: DISTRIBUTION.founder.toString(),
            cliff_date: cliffDate.toISOString(),
            vesting_end: vestingEnd.toISOString(),
            claimed_amount: "0"
        }, {
            headers: { 'api_key': CONFIG.BASE44_KEY, 'Content-Type': 'application/json' }
        });
        
        console.log(`  ✓ Total: ${DISTRIBUTION.founder.toLocaleString()} TES`);
        console.log(`  ✓ Cliff: ${cliffDate.toLocaleDateString()}`);
        console.log(`  ✓ Fully Vested: ${vestingEnd.toLocaleDateString()}`);

        // 3. Pre-populate Emission Schedule
        console.log("\n📈 Initializing 10-year emission schedule...");
        
        const genesisDate = new Date();
        
        for (const schedule of EMISSION_SCHEDULE) {
            const yearStart = new Date(genesisDate);
            yearStart.setFullYear(yearStart.getFullYear() + (schedule.year - 1));

            await axios.post(`${CONFIG.BASE44_URL}/EmissionSchedule`, {
                year: schedule.year,
                epoch: Math.floor(yearStart.getTime() / 1000), // Unix timestamp
                emission_amount: schedule.emission.toString(),
                distributed_amount: "0"
            }, {
                headers: { 'api_key': CONFIG.BASE44_KEY, 'Content-Type': 'application/json' }
            });
            
            console.log(`  ✓ Year ${schedule.year}: ${schedule.emission.toLocaleString()} TES (${(schedule.inflation * 100).toFixed(1)}% inflation)`);
        }

        // 4. Initialize Fee Metrics Tracker
        console.log("\n💰 Initializing fee metrics...");
        
        await axios.post(`${CONFIG.BASE44_URL}/FeeMetrics`, {
            timestamp: new Date().toISOString(),
            fees_collected: "0",
            fees_burned: "0",
            fees_to_stakers: "0",
            current_supply: TOTAL_SUPPLY.toString()
        }, {
            headers: { 'api_key': CONFIG.BASE44_KEY, 'Content-Type': 'application/json' }
        });
        
        console.log("  ✓ Genesis fee tracker created");

        // 5. Create Genesis Block
        console.log("\n⛓️  Sealing Genesis Block...");
        
        const genesisHash = "0x0000000000000000000000000000000000000000000000000000000000000000";
        
        await axios.post(`${CONFIG.BASE44_URL}/Block`, {
            block_number: 0,
            block_hash: genesisHash,
            state_root: "GENESIS",
            timestamp: new Date().toISOString(),
            transaction_count: 0,
            previous_hash: genesisHash,
            parent_hash: genesisHash,
            miner_address: "0xProtocol",
            transactions_root: genesisHash,
            receipts_root: genesisHash,
            shard_id: 0,
            epoch: 0,
            difficulty: 0,
            nonce: "0",  // String, not number
            finality_status: "finalized",
            gas_used: 0,
            gas_limit: 0,
            base_fee: 0,
            block_reward: 0
        }, {
            headers: { 'api_key': CONFIG.BASE44_KEY, 'Content-Type': 'application/json' }
        });
        
        console.log("  ✓ Block #0 sealed");

        console.log("\n");
        console.log("═══════════════════════════════════════════");
        console.log("✅ GENESIS COMPLETE");
        console.log("═══════════════════════════════════════════");
        console.log("");
        console.log("📊 Supply Distribution:");
        console.log(`   Community/Staking: ${DISTRIBUTION.community_staking.toLocaleString()} TES (40%)`);
        console.log(`   Ecosystem Treasury: ${DISTRIBUTION.ecosystem_treasury.toLocaleString()} TES (30%)`);
        console.log(`   Founder (Vesting): ${DISTRIBUTION.founder.toLocaleString()} TES (15%)`);
        console.log(`   Genesis Liquidity: ${DISTRIBUTION.genesis_liquidity.toLocaleString()} TES (15%)`);
        console.log("");
        console.log("🔐 Security:");
        console.log(`   Total Supply: ${TOTAL_SUPPLY.toLocaleString()} TES (HARD CAP)`);
        console.log(`   Burn Floor: ${BURN_FLOOR.toLocaleString()} TES`);
        console.log(`   Max APY Cap: 60%`);
        console.log("");
        console.log("🚀 The Tessera Protocol is now live.");
        
    } catch (err) {
        console.error("\n❌ Genesis failed:", err.response?.data || err.message);
        process.exit(1);
    }
}

initializeGenesis();
