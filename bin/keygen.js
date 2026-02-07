const crypto = require('crypto');

console.log("🔐 TESSERA CRYPTO-GENERATOR");
console.log("----------------------------");

// 1. Generate a random 32-byte Private Key
const privateKey = crypto.randomBytes(32).toString('hex');

// 2. Generate a Public Address (Simplified 0x format)
// In a production chain, this would be a Keccak-256 hash of a public key
const hash = crypto.createHash('sha256').update(privateKey).digest('hex');
const address = "0x" + hash.substring(0, 40).toUpperCase();

console.log(`PUBLIC ADDRESS:  ${address}`);
console.log(`PRIVATE KEY:     ${privateKey}`);
console.log("----------------------------");
console.log("⚠️  NEVER SHARE YOUR PRIVATE KEY.");
console.log("Store this in your 'tessera-keys.txt' file.");
