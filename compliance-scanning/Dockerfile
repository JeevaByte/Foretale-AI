FROM ubuntu:22.04

LABEL maintainer="Foretale-AI"
LABEL description="Complete Compliance Scanning Suite - Trivy, OWASP, OpenScap, CloudMapper, Wazuh"

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    git \
    python3 \
    python3-pip \
    python3-dev \
    openjdk-11-jre-headless \
    apt-transport-https \
    gnupg \
    lsb-release \
    graphviz \
    jq \
    yamllint \
    && rm -rf /var/lib/apt/lists/*

# Install Trivy
RUN wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | apt-key add - && \
    echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | tee -a /etc/apt/sources.list.d/trivy.list && \
    apt-get update && apt-get install -y trivy

# Install OpenScap
RUN apt-get update && apt-get install -y \
    libopenscap8 \
    openscap-scanner \
    scap-security-guide

# Install OWASP tools via pip
RUN pip3 install --no-cache-dir \
    bandit \
    safety \
    semgrep \
    cloudmapper

# Install Checkov (Infrastructure as Code scanning)
RUN pip3 install --no-cache-dir checkov

# Create working directory
WORKDIR /workspace

# Copy compliance scanning scripts
COPY . /opt/compliance-scanning/
RUN chmod +x /opt/compliance-scanning/*.sh && \
    chmod +x /opt/compliance-scanning/*/*.sh

# Create reports directory
RUN mkdir -p /workspace/reports

# Set entry point
ENTRYPOINT ["/bin/bash"]
CMD ["/opt/compliance-scanning/run-all-scans.sh"]
