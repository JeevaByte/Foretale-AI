#!/bin/bash

# Trivy Vulnerability Scanner for Foretale-AI
# Scans: Container images, Filesystems, Git repositories, Kubernetes manifests

set -e

SCAN_DIR="/workspaces/Foretale-AI"
OUTPUT_DIR="${SCAN_DIR}/compliance-scanning/trivy/reports"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "$OUTPUT_DIR"

echo "========================================"
echo "Trivy Vulnerability Scanner"
echo "========================================"
echo ""

# 1. Scan Repository for secrets and vulnerabilities
echo "[*] Scanning repository for vulnerabilities and secrets..."
trivy repo \
    --security-checks secret,vuln,config \
    --format json \
    --output "$OUTPUT_DIR/trivy-repo-${TIMESTAMP}.json" \
    "$SCAN_DIR" || true

trivy repo \
    --security-checks secret,vuln,config \
    --format table \
    --output "$OUTPUT_DIR/trivy-repo-${TIMESTAMP}.txt" \
    "$SCAN_DIR" || true

echo "✓ Repository scan complete: $OUTPUT_DIR/trivy-repo-${TIMESTAMP}.json"
echo ""

# 2. Scan Dockerfile if exists
echo "[*] Scanning Dockerfiles..."
if [ -f "$SCAN_DIR/Dockerfile" ]; then
    trivy config \
        --format json \
        --output "$OUTPUT_DIR/trivy-dockerfile-${TIMESTAMP}.json" \
        "$SCAN_DIR/Dockerfile" || true
    echo "✓ Dockerfile scan complete"
else
    echo "No Dockerfile found in root directory"
fi
echo ""

# 3. Scan Kubernetes manifests
echo "[*] Scanning Kubernetes manifests..."
if [ -d "$SCAN_DIR/infrastructure/kubernetes" ]; then
    trivy config \
        --format json \
        --output "$OUTPUT_DIR/trivy-k8s-${TIMESTAMP}.json" \
        "$SCAN_DIR/infrastructure/kubernetes" || true
    echo "✓ Kubernetes manifests scanned"
fi
echo ""

# 4. Scan Terraform configurations
echo "[*] Scanning Terraform configurations..."
if [ -d "$SCAN_DIR/infrastructure/terraform" ]; then
    trivy config \
        --format json \
        --output "$OUTPUT_DIR/trivy-terraform-${TIMESTAMP}.json" \
        "$SCAN_DIR/infrastructure/terraform" || true
    echo "✓ Terraform configurations scanned"
fi
echo ""

# 5. Scan dependencies
echo "[*] Scanning dependencies..."
trivy fs \
    --security-checks vuln \
    --format json \
    --output "$OUTPUT_DIR/trivy-dependencies-${TIMESTAMP}.json" \
    "$SCAN_DIR" || true

echo "✓ Dependency scan complete"
echo ""

echo "========================================"
echo "Trivy Scan Complete!"
echo "Reports saved to: $OUTPUT_DIR"
echo "========================================"
