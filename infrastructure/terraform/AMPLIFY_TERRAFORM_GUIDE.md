# Amplify App Deployment to us-east-2 via Terraform

This Terraform configuration creates an AWS Amplify app in the us-east-2 region to match the us-east-1 setup.

## Prerequisites

Since the repository is **client-owned**, you have three authentication options:

### Option A: GitHub Personal Access Token (from Client)
- Request PAT from client with `repo` scope
- Client creates token at: https://github.com/settings/tokens
- Less secure: Client must share token with you

### Option B: GitHub Deploy Key (Recommended for Client Repos)
- Request SSH Deploy Key from client (read-only)
- Add to your infrastructure
- More secure: Limited to this repo only, read-only
- Note: Terraform AWS provider doesn't directly support SSH keys, so use Option A or C instead

### Option C: AWS Amplify Console OAuth (No Token Needed)
- Create app manually in AWS Amplify Console
- Amplify handles GitHub OAuth authentication interactively
- More secure: You don't need to store credentials
- Then import into Terraform using `terraform import`

### AWS Credentials
- Already configured in your environment
- Ensure account has IAM permissions to create Amplify apps

## What Gets Created

- **Amplify App** in us-east-2 region
- **Main Branch** configuration (PRODUCTION stage)
- **Build Settings** matching us-east-1 (Flutter web build)
- **Environment Variables** (AI_ASSISTANT_HOST, LIVE_UPDATES)
- **IAM Service Role** reference (amplify-service-role must exist)

## Deployment Steps

### Recommended: Option C - AWS Amplify Console + Terraform Import

**Step 1: Create Amplify App via Console (Client handles GitHub OAuth)**

1. Go to AWS Amplify Console: https://console.aws.amazon.com/amplifyapp/
2. Select region **us-east-2**
3. Click "Create app" → "Deploy an app"
4. Choose "GitHub" 
5. Click "Authorize AWS Amplify on GitHub"
6. Client approves OAuth access to their repository
7. Select repository: `bharath-arcot-babu/foretale_application`
8. Select branch: `main`
9. Note the **App ID** from the URL or settings page

**Step 2: Import into Terraform**

```bash
terraform import aws_amplify_app.foretaleapplication_us_east_2 <APP_ID>
```

Then Terraform manages it going forward.

---

### Alternative: Option A - GitHub Personal Access Token

**Step 1: Get Token from Client**

Request client to:
1. Go to: https://github.com/settings/tokens
2. Click "Generate new token" → "Generate new token (classic)"
3. Select scope: **`repo`** (Full control of private repositories)
4. Copy the token and share securely

**Step 2: Deploy via Terraform**

**Step 2: Deploy via Terraform**

Using PowerShell (Windows):

```powershell
# Set GitHub token (from client)
$env:GITHUB_TOKEN = "ghp_xxxx..."

# Run deployment script
.\deploy_amplify_us_east_2.ps1
```

Using Bash (Linux/macOS):

```bash
# Set GitHub token (from client)
export GITHUB_TOKEN="ghp_xxxx..."

# Run deployment script
./deploy_amplify_us_east_2.sh
```

Using Terraform directly:

```bash
# Create tfvars file
cp amplify.tfvars.example amplify.tfvars
# Edit and add token from client: github_token = "ghp_xxxx..."

terraform plan -var-file="amplify.tfvars"
terraform apply -var-file="amplify.tfvars"
```

---

### Option 3: Using PowerShell (Windows)

## Important Notes

⚠️ **Client-Owned Repository:**
- You don't own the GitHub repository - client does
- **Recommended approach:** Use AWS Amplify Console OAuth (no credentials needed)
- **Alternative:** Request GitHub PAT from client (minimal permissions)
- **Never store credentials** in Terraform code or version control
- Document this in your runbook: "GitHub token provided by client"

⚠️ **Security:**
- Never commit the GitHub token to Git
- Add `amplify.tfvars` to `.gitignore` (already in example file)
- Use environment variables instead of hardcoding in files
- Request new token from client periodically (90 days)
- **Preferred:** Use AWS Amplify Console OAuth - credentials handled by AWS/GitHub, not stored locally

⚠️ **Backend Environments:**
- This Terraform creates the **Amplify App only**
- Backend environments (Auth, Storage, API) require Amplify CLI
- After app is created, run:
  ```bash
  amplify init --region us-east-2
  amplify push
  ```

## Outputs

After deployment, Terraform outputs:
- `amplify_app_id_us_east_2` - App ID for reference
- `amplify_app_arn_us_east_2` - Full ARN
- `amplify_default_domain_us_east_2` - Default deployment domain
- `amplify_repository_url` - Repository URL configured

Example:
```
amplify_app_id_us_east_2 = "d1abc2defg3h"
amplify_default_domain_us_east_2 = "d1abc2defg3h.amplifyapp.com"
amplify_repository_url = "https://github.com/bharath-arcot-babu/foretale_application"
```

## GitHub Token Setup (If Using Option A)

### Step 1: Request Token from Client

Since repository is client-owned, request they create a Personal Access Token:

1. Client goes to: https://github.com/settings/tokens
2. Client clicks "Generate new token" → "Generate new token (classic)"
3. Client enters name: `terraform-amplify-us-east-2` (or similar)
4. Client sets expiration: 90 days (recommended)
5. Client selects scope: **`repo`** (Full control of private repositories)
6. Client clicks "Generate token"
7. Client copies token and shares securely with you

### Step 2: Use Token in Terraform

**Option A: Environment Variable (Recommended)**
```powershell
# PowerShell
$env:GITHUB_TOKEN = "ghp_xxxx..." # from client
.\deploy_amplify_us_east_2.ps1
```

**Option B: tfvars File**
```hcl
# amplify.tfvars (add to .gitignore)
github_token = "ghp_xxxx..." # from client
```

**Option C: Command Line**
```bash
terraform plan -var="github_token=ghp_xxxx..."
```

### Security Notes

⚠️ **For Client-Owned Repos:**
- **Recommended:** Ask client to create token with minimal access
- **Never** commit token to Git repository
- **Store securely:** Use AWS Secrets Manager or client's token management
- **Rotate:** Request new token from client periodically (90 days)
- **Prefer:** Use AWS Amplify Console OAuth (Option C) - no credentials needed

## Troubleshooting

### Error: "You should at least provide one valid token"
- GitHub token is not set or is invalid
- Check token has `repo` scope
- Token may have expired

### Error: "Repository access denied"
- Token doesn't have `repo` scope
- Token doesn't have access to the repository
- Repository may be under an organization with additional restrictions

### Error: "iam:role/amplify-service-role does not exist"
- The Amplify service role hasn't been created yet
- Create it first or reference an existing role

### Build fails in Amplify Console
- Ensure Flutter SDK is available in the build environment
- Check buildspec matches your Flutter version
- Verify `flutter pub get` resolves all dependencies

## Next Steps After Deployment

1. **Verify App Creation**
   ```bash
   aws amplify get-app --app-id <APP_ID> --region us-east-2
   ```

2. **Manually Connect Branch (if not auto-connected)**
   - Go to AWS Amplify Console
   - Select the app
   - Click "Connect repository" if needed

3. **Deploy Backend (via Amplify CLI)**
   ```bash
   cd foretale_application
   amplify init --region us-east-2 --envName dev
   amplify push
   ```

4. **Test Build**
   - Amplify will automatically build from the main branch
   - Monitor in Amplify Console
   - View build logs if issues occur

## Cleanup

To remove the Amplify app from us-east-2:

```bash
terraform destroy -var-file="amplify.tfvars"
```

## References

- [AWS Amplify Terraform Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/amplify_app)
- [GitHub Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)
- [AWS Amplify Documentation](https://docs.aws.amazon.com/amplify/)
- [Amplify CLI Reference](https://docs.amplify.aws/cli/)
