#!/usr/bin/env node

/**
 * Apple Sign-In JWT Client Secret Generator
 * 
 * This script generates a JWT client secret required for Apple Sign-In with Supabase.
 * The JWT is signed using the Apple private key (.p8 file) with ES256 algorithm.
 */

const jwt = require('jsonwebtoken');
const fs = require('fs');
const path = require('path');

// Configuration
const TEAM_ID = "N5386872HH";
const KEY_ID = "GP3673B968"; // Extracted from your AuthKey_GP3673B968.p8 filename
const SERVICE_ID = "com.umursoganci.mealadvisor.service";
const PRIVATE_KEY_PATH = "./AuthKey_GP3673B968.p8";

// JWT Configuration
const AUDIENCE = "https://appleid.apple.com";
const ALGORITHM = "ES256";

/**
 * Generate Apple Sign-In JWT Client Secret
 */
function generateAppleJWT() {
    try {
        console.log("🍎 [Apple JWT Generator] Starting JWT generation...");
        console.log("🍎 [Apple JWT Generator] Team ID:", TEAM_ID);
        console.log("🍎 [Apple JWT Generator] Key ID:", KEY_ID);
        console.log("🍎 [Apple JWT Generator] Service ID:", SERVICE_ID);
        console.log("🍎 [Apple JWT Generator] Private Key Path:", PRIVATE_KEY_PATH);
        
        // Check if private key file exists
        if (!fs.existsSync(PRIVATE_KEY_PATH)) {
            throw new Error(`Private key file not found: ${PRIVATE_KEY_PATH}`);
        }
        
        // Read the private key
        console.log("🍎 [Apple JWT Generator] Reading private key...");
        const privateKey = fs.readFileSync(PRIVATE_KEY_PATH, 'utf8');
        console.log("✅ [Apple JWT Generator] Private key loaded successfully");
        
        // Current time
        const now = Math.floor(Date.now() / 1000);
        const issuedAt = now;
        const expiration = now + (6 * 30 * 24 * 60 * 60); // 6 months from now
        
        console.log("🍎 [Apple JWT Generator] JWT Claims:");
        console.log("  - iss (Team ID):", TEAM_ID);
        console.log("  - iat (Issued At):", new Date(issuedAt * 1000).toISOString());
        console.log("  - exp (Expiration):", new Date(expiration * 1000).toISOString());
        console.log("  - aud (Audience):", AUDIENCE);
        console.log("  - sub (Service ID):", SERVICE_ID);
        
        // JWT Payload
        const payload = {
            iss: TEAM_ID,           // Team ID
            iat: issuedAt,          // Issued at (current time)
            exp: expiration,        // Expiration (6 months from now)
            aud: AUDIENCE,          // Audience
            sub: SERVICE_ID         // Service ID (Subject)
        };
        
        // JWT Header
        const header = {
            kid: KEY_ID,            // Key ID
            alg: ALGORITHM          // Algorithm (ES256)
        };
        
        console.log("🍎 [Apple JWT Generator] Signing JWT with ES256 algorithm...");
        
        // Sign the JWT
        const token = jwt.sign(payload, privateKey, {
            algorithm: ALGORITHM,
            header: header
        });
        
        console.log("✅ [Apple JWT Generator] JWT generated successfully!");
        console.log("✅ [Apple JWT Generator] JWT Length:", token.length, "characters");
        console.log("✅ [Apple JWT Generator] JWT expires in 6 months");
        
        // Output the JWT
        console.log("\n" + "=".repeat(80));
        console.log("APPLE SIGN-IN JWT CLIENT SECRET:");
        console.log("=".repeat(80));
        console.log(token);
        console.log("=".repeat(80));
        
        console.log("\n🍎 [Apple JWT Generator] Copy the JWT above and paste it into Supabase Dashboard:");
        console.log("   1. Go to Supabase Dashboard → Authentication → Providers → Apple");
        console.log("   2. Paste this JWT as the 'Client Secret'");
        console.log("   3. Set Service ID to:", SERVICE_ID);
        console.log("   4. Set Key ID to:", KEY_ID);
        console.log("   5. Enable Apple provider");
        
        return token;
        
    } catch (error) {
        console.error("❌ [Apple JWT Generator] Error generating JWT:");
        console.error("❌ [Apple JWT Generator] Error:", error.message);
        
        if (error.code === 'MODULE_NOT_FOUND') {
            console.error("\n💡 [Apple JWT Generator] Missing dependency. Run:");
            console.error("   npm install jsonwebtoken");
        }
        
        process.exit(1);
    }
}

// Run the generator
if (require.main === module) {
    generateAppleJWT();
}

module.exports = { generateAppleJWT };
