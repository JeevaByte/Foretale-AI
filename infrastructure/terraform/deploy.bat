@echo off
REM ForeTale Infrastructure Deployment Script for Windows
REM Phase 1: Core Infrastructure and Networking

setlocal enabledelayedexpansion

echo ==================================
echo ForeTale Infrastructure Deployment
echo Phase 1: Core Infrastructure
echo ==================================
echo.

REM Check Terraform
where terraform >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Terraform is not installed. Please install Terraform first.
    exit /b 1
)
echo [INFO] Terraform found: 
terraform --version | findstr /C:"Terraform"
echo.

REM Check AWS CLI
where aws >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] AWS CLI is not installed. Please install AWS CLI first.
    exit /b 1
)
echo [INFO] AWS CLI found
echo.

REM Check AWS credentials
aws sts get-caller-identity >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] AWS credentials not configured. Please run 'aws configure'.
    exit /b 1
)
echo [INFO] AWS credentials verified
echo.

REM Create terraform.tfvars if it doesn't exist
if not exist "terraform.tfvars" (
    echo [WARNING] terraform.tfvars not found. Creating from example...
    copy terraform.tfvars.example terraform.tfvars
    echo [INFO] Created terraform.tfvars. Please review and update values.
    pause
)

REM Initialize Terraform
echo [INFO] Initializing Terraform...
terraform init -upgrade
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Terraform initialization failed
    exit /b 1
)
echo.

REM Validate configuration
echo [INFO] Validating Terraform configuration...
terraform validate
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Terraform validation failed
    exit /b 1
)
echo.

REM Format files
echo [INFO] Formatting Terraform files...
terraform fmt -recursive
echo.

REM Create plan
echo [INFO] Creating Terraform plan...
terraform plan -out=tfplan
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Terraform plan failed
    exit /b 1
)
echo.

REM Confirm deployment
echo [WARNING] Review the plan above carefully.
set /p confirm="Do you want to continue with deployment? (yes/no): "
if /i not "%confirm%"=="yes" (
    echo [INFO] Deployment cancelled.
    exit /b 0
)

REM Apply deployment
echo.
echo [INFO] Applying Terraform configuration...
terraform apply tfplan
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Terraform apply failed
    exit /b 1
)

REM Clean up plan file
del tfplan

REM Show outputs
echo.
echo [INFO] Deployment completed successfully!
echo.
echo [INFO] Infrastructure Outputs:
terraform output

REM Save outputs
echo.
echo [INFO] Saving outputs to outputs.json...
terraform output -json > outputs.json
echo [INFO] Outputs saved to outputs.json

echo.
echo [INFO] Next Steps:
echo   1. Review the outputs above
echo   2. Verify resources in AWS Console
echo   3. Proceed with Phase 2 deployment
echo.
echo [INFO] To destroy this infrastructure, run: terraform destroy
echo.

pause
