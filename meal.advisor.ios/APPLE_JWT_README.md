# Apple Sign-In JWT Generator

This script generates the JWT client secret required for Apple Sign-In with Supabase.

## Quick Start

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Run the script:**
   ```bash
   node apple_jwt.js
   ```

3. **Copy the generated JWT** and paste it into your Supabase Dashboard.

## Configuration

The script is pre-configured with your Apple credentials:

- **Team ID**: `N5386872HH`
- **Key ID**: `GP3673B968` (extracted from your AuthKey filename)
- **Service ID**: `com.umursoganci.mealadvisor.service`
- **Private Key**: `AuthKey_GP3673B968.p8`

## JWT Details

The generated JWT includes these claims:
- `iss` (issuer): Your Apple Team ID
- `iat` (issued at): Current timestamp
- `exp` (expiration): 6 months from now
- `aud` (audience): `https://appleid.apple.com`
- `sub` (subject): Your Service ID

## Supabase Configuration

After generating the JWT:

1. Go to **Supabase Dashboard** → **Authentication** → **Providers** → **Apple**
2. Enable Apple provider
3. Set **Service ID**: `com.umursoganci.mealadvisor.service`
4. Set **Key ID**: `GP3673B968`
5. Paste the generated JWT as **Client Secret**
6. Save configuration

## Security Notes

- The JWT expires in 6 months
- Regenerate the JWT before expiration
- Keep your private key file secure
- Never commit the private key to version control

## Troubleshooting

If you get a "MODULE_NOT_FOUND" error:
```bash
npm install jsonwebtoken
```

If the private key file is not found:
- Ensure `AuthKey_GP3673B968.p8` is in the same directory as the script
- Check the filename matches exactly
