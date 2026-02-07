#!/usr/bin/env node

const axios = require('axios');

const CONFIG = {
    BASE44_URL: "https://app.base44.com/api/apps/6984c2570cad7b023d66ae06/entities",
    BASE44_KEY: "YOUR_BASE44_KEY_PLACEHOLDER",
    GATEWAY: "http://localhost:3000"
};

const MAX_APY = 0.60; // 60% cap
const SECONDS_PER_YEAR = 31536000;

// Get current emission year based on genesis date
async function getCurrentEmissionYear() {
    const schedules = await axios.get(`${CONFIG.BASE44_URL}/EmissionSchedule`, {
        headers: { 'api_key': CONFIG.BASE44_KEY }
    });
    
    const genesis = new Date(schedules.data[0].epoch);
    const now = new Date();
    const yearsSinceGenesis = (now - genesis) / (1000 * SECONDS_PER_YEAR);
    
    return Math.floor(yearsSinceGenesis) + 1;
}

// Calculate current emission rate per second
async function getEmissionRate() {
    const currentYear = await getCurrentEmissionYear();
    
    const schedules = await axios.get(`${CONFIG.BASE44_URL}/EmissionSchedule`, {
        headers: { 'api_key': CONFIG.BASE44_KEY }
    });
    
    const yearSchedule = schedules.data.find(s => s.year === currentYear);
    if (!yearSchedule) return 0;
    
    return parseFloat(yearSchedule.emission_amount) / SECONDS_PER_YEAR;
}

// Get total staked amount
async function getTotalStaked() {
    const positions = await axios.get(`${CONFIG.BASE44_URL}/StakingPosition`, {
        headers: { 'api_key': CONFIG.BASE44_KEY }
    });
    
    return positions.data.reduce((sum, pos) => sum + parseFloat(pos.staked_amount), 0);
}

// Calculate rewards for a staking position
async function calculateRewards(position) {
    const now = new Date();
    const stakeDate = new Date(position.stake_date);
    const secondsStaked = (now - stakeDate) / 1000;
    
    const emissionRate = await getEmissionRate();
    const totalStaked = await getTotalStaked();
    
    if (totalStaked === 0) return 0;
    
    const stakerShare = parseFloat(position.staked_amount) / totalStaked;
    const rawRewards = emissionRate * secondsStaked * stakerShare;
    
    // Apply 60% APY cap
    const yearlyRewards = rawRewards * (SECONDS_PER_YEAR / secondsStaked);
    const effectiveAPY = yearlyRewards / parseFloat(position.staked_amount);
    
    if (effectiveAPY > MAX_APY) {
        // Cap applied - scale down rewards
        const cappedYearlyRewards = parseFloat(position.staked_amount) * MAX_APY;
        return (cappedYearlyRewards / SECONDS_PER_YEAR) * secondsStaked;
    }
    
    return rawRewards;
}

// Stake tokens
async function stake(address, amount, privateKey) {
    console.log(`🔒 STAKING ${amount} TES for ${address}`);
    
    try {
        // 1. Check account balance
        const account = await axios.get(`${CONFIG.GATEWAY}/Account/${address}`);
        const balance = parseFloat(account.data.balance);
        
        if (balance < amount) {
            throw new Error(`Insufficient balance: ${balance} < ${amount}`);
        }
        
        // 2. Check if staking position exists
        const positions = await axios.get(`${CONFIG.BASE44_URL}/StakingPosition`, {
            headers: { 'api_key': CONFIG.BASE44_KEY }
        });
        
        const existing = positions.data.find(p => p.address === address);
        
        if (existing) {
            // Claim existing rewards before adding more stake
            const rewards = await calculateRewards(existing);
            const newStaked = parseFloat(existing.staked_amount) + amount;
            const newRewards = parseFloat(existing.rewards_earned) + rewards;
            
            await axios.put(`${CONFIG.BASE44_URL}/StakingPosition/${existing.id}`, {
                address,
                staked_amount: newStaked.toString(),
                stake_date: existing.stake_date, // Keep original date
                rewards_earned: newRewards.toString(),
                last_claim: new Date().toISOString()
            }, {
                headers: { 'api_key': CONFIG.BASE44_KEY, 'Content-Type': 'application/json' }
            });
            
            console.log(`  ✓ Updated position: ${newStaked} TES staked`);
            console.log(`  ✓ Unclaimed rewards: ${newRewards.toFixed(2)} TES`);
        } else {
            // Create new staking position
            await axios.post(`${CONFIG.BASE44_URL}/StakingPosition`, {
                address,
                staked_amount: amount.toString(),
                stake_date: new Date().toISOString(),
                rewards_earned: "0",
                last_claim: new Date().toISOString()
            }, {
                headers: { 'api_key': CONFIG.BASE44_KEY, 'Content-Type': 'application/json' }
            });
            
            console.log(`  ✓ New staking position created`);
        }
        
        // 3. Lock tokens by reducing account balance
        const newBalance = balance - amount;
        await axios.post(`${CONFIG.GATEWAY}/Account`, {
            address,
            balance: newBalance.toString(),
            nonce: account.data.nonce + 1
        });
        
        console.log(`  ✓ ${amount} TES locked in staking`);
        console.log(`  ✓ Remaining balance: ${newBalance} TES`);
        
    } catch (err) {
        console.error("❌ Staking failed:", err.response?.data || err.message);
        throw err;
    }
}

// Claim staking rewards
async function claimRewards(address) {
    console.log(`💰 CLAIMING REWARDS for ${address}`);
    
    try {
        const positions = await axios.get(`${CONFIG.BASE44_URL}/StakingPosition`, {
            headers: { 'api_key': CONFIG.BASE44_KEY }
        });
        
        const position = positions.data.find(p => p.address === address);
        if (!position) {
            throw new Error("No staking position found");
        }
        
        // Calculate pending rewards
        const pendingRewards = await calculateRewards(position);
        const totalRewards = parseFloat(position.rewards_earned) + pendingRewards;
        
        if (totalRewards === 0) {
            console.log("  ℹ️  No rewards to claim");
            return;
        }
        
        // Update position - reset rewards to 0
        await axios.put(`${CONFIG.BASE44_URL}/StakingPosition/${position.id}`, {
            ...position,
            rewards_earned: "0",
            last_claim: new Date().toISOString()
        }, {
            headers: { 'api_key': CONFIG.BASE44_KEY, 'Content-Type': 'application/json' }
        });
        
        // Add rewards to account balance
        const account = await axios.get(`${CONFIG.GATEWAY}/Account/${address}`);
        const newBalance = parseFloat(account.data.balance) + totalRewards;
        
        await axios.post(`${CONFIG.GATEWAY}/Account`, {
            address,
            balance: newBalance.toString(),
            nonce: account.data.nonce + 1
        });
        
        console.log(`  ✓ Claimed: ${totalRewards.toFixed(2)} TES`);
        console.log(`  ✓ New balance: ${newBalance.toFixed(2)} TES`);
        
    } catch (err) {
        console.error("❌ Claim failed:", err.response?.data || err.message);
        throw err;
    }
}

// View staking stats
async function viewStats(address) {
    const positions = await axios.get(`${CONFIG.BASE44_URL}/StakingPosition`, {
        headers: { 'api_key': CONFIG.BASE44_KEY }
    });
    
    const totalStaked = await getTotalStaked();
    const emissionRate = await getEmissionRate();
    const currentYear = await getCurrentEmissionYear();
    
    console.log("📊 TESSERA STAKING STATS");
    console.log("========================");
    console.log(`Current Year: ${currentYear}`);
    console.log(`Emission Rate: ${(emissionRate * SECONDS_PER_YEAR).toLocaleString()} TES/year`);
    console.log(`Total Staked: ${totalStaked.toLocaleString()} TES`);
    console.log("");
    
    if (address) {
        const position = positions.data.find(p => p.address === address);
        if (position) {
            const pendingRewards = await calculateRewards(position);
            const totalRewards = parseFloat(position.rewards_earned) + pendingRewards;
            const apr = (totalRewards / parseFloat(position.staked_amount)) * (SECONDS_PER_YEAR / ((new Date() - new Date(position.stake_date)) / 1000));
            
            console.log(`Your Position:`);
            console.log(`  Staked: ${parseFloat(position.staked_amount).toLocaleString()} TES`);
            console.log(`  Pending Rewards: ${totalRewards.toFixed(2)} TES`);
            console.log(`  Current APY: ${(apr * 100).toFixed(2)}%`);
        } else {
            console.log(`No staking position found for ${address}`);
        }
    }
}

// CLI
const command = process.argv[2];
const address = process.argv[3];
const amount = parseFloat(process.argv[4]);

if (command === 'stake' && address && amount) {
    stake(address, amount);
} else if (command === 'claim' && address) {
    claimRewards(address);
} else if (command === 'stats') {
    viewStats(address);
} else {
    console.log("Usage:");
    console.log("  node bin/staking.js stake <address> <amount>");
    console.log("  node bin/staking.js claim <address>");
    console.log("  node bin/staking.js stats [address]");
}
