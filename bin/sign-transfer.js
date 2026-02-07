#!/usr/bin/env node

const crypto = require('crypto');
const axios = require('axios');

const GATEWAY = "http://localhost:3000";

// Parse command line args
const args = process.argv.slice(2);
if (args.length !== 4) {
    console.log("Usage: node bin/sign-transfer.js <from_address> <to_address> <amount> <private_key>");
    console.log("Example: node bin/sign-transfer.js 0x5C42... 0xD94D... 100 1325ed34...");
    process.exit(1);
}

const [fromAddr, toAddr, amount, privateKey] = args;

async function signAndSendTransfer() {
    console.log("🔐 TESSERA SECURE TRANSFER");
    console.log("===========================");
    
    try {
        // 1. Get sender's current nonce
        console.log("📡 Fetching sender state...");
        const senderResp = await axios.get(`${GATEWAY}/Account/${fromAddr}`);
        const currentNonce = senderResp.data.nonce || 0;
        const newNonce = currentNonce + 1;
        
        console.log(`   Current nonce: ${currentNonce}`);
        console.log(`   Next nonce: ${newNonce}`);
        
        // 2. Create transaction data
        const txData = {
            from_address: fromAddr,
            to_address: toAddr,
            amount: amount,
            nonce: newNonce,
            timestamp: new Date().toISOString()
        };
        
        // 3. Create message to sign (deterministic ordering)
        const message = `${txData.from_address}:${txData.to_address}:${txData.amount}:${txData.nonce}:${txData.timestamp}`;
        console.log(`\n📝 Message: ${message}`);
        
        // 4. Sign the message with private key
        const signature = crypto
            .createHmac('sha256', privateKey)
            .update(message)
            .digest('hex');
        
        console.log(`✍️  Signature: ${signature.substring(0, 16)}...`);
        
        // 5. Create transaction hash
        const txHash = crypto
            .createHash('sha256')
            .update(message + signature)
            .digest('hex');
        
        console.log(`🔗 TX Hash: ${txHash.substring(0, 16)}...`);
        
        // 6. Send signed transaction to gateway
        const signedTx = {
            ...txData,
            signature,
            tx_hash: txHash
        };
        
        console.log(`   Signed TX (before sending): ${JSON.stringify(signedTx, null, 2)}`);
        console.log("\n📤 Sending signed transaction to gateway...");
        const txResp = await axios.post(`${GATEWAY}/Transaction`, signedTx, {
            headers: { 'Content-Type': 'application/json' }
        });
        
        console.log("\n✅ TRANSACTION SUBMITTED");
        console.log(`💰 ${amount} TES: ${fromAddr.substring(0,10)}... → ${toAddr.substring(0,10)}...`);
        console.log(`🔗 TX: ${txHash}`);
        console.log(`📦 Status: ${txResp.data.status}`);
        
    } catch (err) {
        console.error("\n❌ TRANSFER FAILED:", err.response?.data || err.message);
        process.exit(1);
    }
}

signAndSendTransfer();
