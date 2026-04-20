#!/bin/bash

# Foretale-AI Compliance Scanning Suite Installation Script
# Installs: Trivy, OWASP Compliance, OpenScap, CloudMapper, Wazuh Agent

set -e

echo "=====================================================";
echo "Foretale-AI Compliance Scanning Setup"
echo "=====================================================";
echo ""

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
fi

echo "[*] Detected OS: $OS"
echo ""

# 1. Install Trivy
echo "[1] Installing Trivy Vulnerability Scanner..."
if ! command -v trivy &> /dev/null; then
    if [[ "$OS" == "linux" ]]; then
        wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | apt-key add -
        echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | tee -a /etc/apt/sources.list.d/trivy.list
        apt-get update && apt-get install -y trivy
    elif [[ "$OS" == "macos" ]]; then
        brew install trivy
    fi
    echo "✓ Trivy installed successfully"
else
    echo "✓ Trivy already installed"
fi
echo ""

# 2. Install OWASP ZAP (for OWASP Compliance)
echo "[2] Installing OWASP ZAP & Compliance Tools..."
if ! command -v zaproxy &> /dev/null; then
    if [[ "$OS" == "linux" ]]; then
        apt-get install -y apt-transport-https lsb-release gnupg
        wget https://zaproxy.blob.core.windows.net/files/ZAPInstaller_2.14.1.zip -O /tmp/zap.zip
        unzip -q /tmp/zap.zip -d /opt/
        rm /tmp/zap.zip
    elif [[ "$OS" == "macos" ]]; then
        brew install --cask owasp-zap
    fi
    echo "✓ OWASP ZAP installed successfully"
else
    echo "✓ OWASP ZAP already installed"
fi
echo ""

# 3. Install OpenScap
echo "[3] Installing OpenScap NIST/CIS Compliance..."
if ! command -v oscap &> /dev/null; then
    if [[ "$OS" == "linux" ]]; then
        apt-get install -y libopenscap8 openscap-scanner scap-security-guide
    elif [[ "$OS" == "macos" ]]; then
        brew install openscap-daemon
    fi
    echo "✓ OpenScap installed successfully"
else
    echo "✓ OpenScap already installed"
fi
echo ""

# 4. Install CloudMapper
echo "[4] Installing CloudMapper for AWS Compliance..."
if ! command -v cloudmapper &> /dev/null; then
    apt-get install -y python3-pip graphviz
    pip3 install cloudmapper
    echo "✓ CloudMapper installed successfully"
else
    echo "✓ CloudMapper already installed"
fi
echo ""

# 5. Install Wazuh Agent
echo "[5] Installing Wazuh Agent for SOC2 Compliance..."
apt-get install -y curl
WAZUH_VERSION="4.7.0"
if [[ "$OS" == "linux" ]]; then
    if [[ "$DISTRO" == "ubuntu" ]] || [[ "$DISTRO" == "debian" ]]; then
        curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add -
        echo "deb https://packages.wazuh.com/4.x/apt/ stable main" > /etc/apt/sources.list.d/wazuh.list
        apt-get update && apt-get install -y wazuh-agent=${WAZUH_VERSION}*
        systemctl daemon-reload
        echo "✓ Wazuh Agent installed successfully"
    fi
fi
echo ""

# 6. Install additional dependencies
echo "[6] Installing additional tools..."
apt-get install -y \
    git \
    python3-dev \
    python3-pip \
    jq \
    yamllint \
    checkov

pip3 install --upgrade \
    bandit \
    safety \
    semgrep

echo "✓ Additional tools installed"
echo ""

echo "=====================================================";
echo "Installation Complete!"
echo "=====================================================";
echo ""
echo "Next Steps:"
echo "1. Configure Wazuh Agent: /var/ossec/bin/wazuh-control start"
echo "2. Run Trivy scan: trivy image <image-name>"
echo "3. Run OpenScap scan: ./openscap/run-openscap-scan.sh"
echo "4. Run CloudMapper: ./cloudmapper/run-cloudmapper.sh"
echo "5. Run OWASP scan: ./owasp/run-owasp-scan.sh"
echo ""
