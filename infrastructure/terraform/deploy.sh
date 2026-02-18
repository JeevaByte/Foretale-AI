#!/bin/bash

################################################################################
# ForeTale Infrastructure Deployment Script
# Phase 1: Core Infrastructure and Networking
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check Terraform
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform first."
        exit 1
    fi
    print_info "Terraform version: $(terraform --version | head -n1)"
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install AWS CLI first."
        exit 1
    fi
    print_info "AWS CLI version: $(aws --version)"
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials not configured. Please run 'aws configure'."
        exit 1
    fi
    print_info "AWS Account: $(aws sts get-caller-identity --query Account --output text)"
    print_info "AWS Region: $(aws configure get region)"
}

# Function to initialize Terraform
init_terraform() {
    print_info "Initializing Terraform..."
    terraform init -upgrade
}

# Function to validate Terraform configuration
validate_terraform() {
    print_info "Validating Terraform configuration..."
    terraform validate
}

# Function to format Terraform files
format_terraform() {
    print_info "Formatting Terraform files..."
    terraform fmt -recursive
}

# Function to create terraform.tfvars if it doesn't exist
create_tfvars() {
    if [ ! -f "terraform.tfvars" ]; then
        print_warning "terraform.tfvars not found. Creating from example..."
        cp terraform.tfvars.example terraform.tfvars
        print_info "Created terraform.tfvars. Please review and update values."
        read -p "Press Enter to continue after reviewing terraform.tfvars..."
    fi
}

# Function to plan deployment
plan_deployment() {
    print_info "Creating Terraform plan..."
    terraform plan -out=tfplan
    
    print_warning "Review the plan above carefully."
    read -p "Do you want to continue with deployment? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        print_info "Deployment cancelled."
        exit 0
    fi
}

# Function to apply deployment
apply_deployment() {
    print_info "Applying Terraform configuration..."
    terraform apply tfplan
    
    # Clean up plan file
    rm -f tfplan
}

# Function to show outputs
show_outputs() {
    print_info "Deployment completed successfully!"
    echo ""
    print_info "Infrastructure Outputs:"
    terraform output
}

# Function to save outputs to file
save_outputs() {
    print_info "Saving outputs to outputs.json..."
    terraform output -json > outputs.json
    print_info "Outputs saved to outputs.json"
}

# Main deployment flow
main() {
    echo "=================================="
    echo "ForeTale Infrastructure Deployment"
    echo "Phase 1: Core Infrastructure"
    echo "=================================="
    echo ""
    
    check_prerequisites
    create_tfvars
    init_terraform
    validate_terraform
    format_terraform
    plan_deployment
    apply_deployment
    show_outputs
    save_outputs
    
    echo ""
    print_info "Next Steps:"
    echo "  1. Review the outputs above"
    echo "  2. Verify resources in AWS Console"
    echo "  3. Proceed with Phase 2 deployment"
    echo ""
    print_info "To destroy this infrastructure, run: terraform destroy"
}

# Run main function
main
