#!/bin/bash
# Deploy Amplify app to us-east-2 via Terraform

set -e

REGION="us-east-2"
GITHUB_TOKEN="${GITHUB_TOKEN:=""}"

if [ -z "$GITHUB_TOKEN" ]; then
    echo "ERROR: GITHUB_TOKEN environment variable not set"
    echo "Create a GitHub PAT at: https://github.com/settings/tokens"
    echo "Required scopes: repo (full control)"
    echo ""
    echo "Usage: GITHUB_TOKEN='ghp_xxxx...' ./deploy_amplify_us_east_2.sh"
    exit 1
fi

echo "Deploying Amplify app to $REGION..."
echo ""

# Plan
terraform plan \
    -var="github_token=$GITHUB_TOKEN" \
    -var="aws_region=$REGION" \
    -out=tfplan_amplify

echo ""
echo "Review the plan above and type 'yes' to apply:"
read -p "Apply? " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Deployment cancelled"
    exit 0
fi

# Apply
terraform apply tfplan_amplify

echo ""
echo "Amplify app deployment complete!"
terraform output -json | grep -E "amplify_app_id_us_east_2|amplify_default_domain_us_east_2" || true
