# Healthcare Agent Orchestrator - Quick Deploy Script
# This script provides a non-interactive deployment of the Healthcare Agent infrastructure

param(
    [Parameter(Mandatory=$false)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroup,
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "westus",
    
    [Parameter(Mandatory=$false)]
    [string]$EnvironmentName = "dev",
    
    [Parameter(Mandatory=$false)]
    [switch]$Force,
    
    [Parameter(Mandatory=$false)]
    [switch]$AutoApprove
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Log file setup
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logDir = Join-Path $PSScriptRoot "logs"
$logFile = Join-Path $logDir "quick_deploy_$timestamp.log"

# Check if log directory exists, create if it doesn't
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}

# Start logging
Start-Transcript -Path $logFile -Append

Write-Host "======================================================" -ForegroundColor Blue
Write-Host " Healthcare Agent Orchestrator - Quick Deploy " -ForegroundColor Blue
Write-Host "======================================================" -ForegroundColor Blue
Write-Host "Log file: $logFile" -ForegroundColor Gray

# Check prerequisites
Write-Host "`nChecking prerequisites..." -ForegroundColor Blue

try {
    $azVersion = az --version
    Write-Host "✓ Azure CLI installed" -ForegroundColor Green
}
catch {
    Write-Error "Azure CLI not found. Please install it from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
}

try {
    $tfVersion = terraform --version
    Write-Host "✓ Terraform installed" -ForegroundColor Green
}
catch {
    Write-Error "Terraform not found. Please install it from: https://developer.hashicorp.com/terraform/downloads"
    exit 1
}

# Login to Azure if not already logged in
Write-Host "`nChecking Azure login..." -ForegroundColor Blue
$loginStatus = az account show 2>$null

if (-not $?) {
    Write-Host "Not logged in to Azure. Logging in..." -ForegroundColor Yellow
    az login
    
    if (-not $?) {
        Write-Error "Failed to login to Azure"
        exit 1
    }
}
else {
    Write-Host "✓ Already logged in to Azure" -ForegroundColor Green
}

# Set subscription if provided
if ($SubscriptionId) {
    Write-Host "Setting subscription to: $SubscriptionId" -ForegroundColor Blue
    az account set --subscription $SubscriptionId
    
    if (-not $?) {
        Write-Error "Failed to set subscription"
        exit 1
    }
}
else {
    # Get current subscription
    $currentSub = (az account show --query id -o tsv)
    $SubscriptionId = $currentSub
    Write-Host "Using current subscription: $SubscriptionId" -ForegroundColor Blue
}

# Check if resource group is provided
if (-not $ResourceGroup) {
    Write-Host "Resource group name is required" -ForegroundColor Yellow
    $ResourceGroup = Read-Host "Enter resource group name"
}

# Check if resource group exists, create if not
$rgExists = az group exists --name $ResourceGroup
if ($rgExists -eq "false") {
    Write-Host "Resource group '$ResourceGroup' does not exist. Creating it..." -ForegroundColor Yellow
    az group create --name $ResourceGroup --location $Location
    
    if (-not $?) {
        Write-Error "Failed to create resource group"
        exit 1
    }
    
    Write-Host "✓ Resource group created" -ForegroundColor Green
}
else {
    Write-Host "✓ Resource group exists" -ForegroundColor Green
}

# Create Terraform variables file
$tfvarsContent = @"
subscription_id = "$SubscriptionId"
resource_group_name = "$ResourceGroup"
location = "$Location"
environment_name = "$EnvironmentName"
openai_model = "gpt-4o;2024-08-06"
openai_model_capacity = 100
openai_model_sku = "GlobalStandard"
"@

Write-Host "Creating terraform.tfvars file..." -ForegroundColor Blue
$tfvarsContent | Out-File -FilePath (Join-Path $PSScriptRoot "terraform.tfvars") -Force
Write-Host "✓ terraform.tfvars created" -ForegroundColor Green

# Initialize Terraform
Write-Host "`nInitializing Terraform..." -ForegroundColor Blue
terraform init

if (-not $?) {
    Write-Error "Terraform initialization failed"
    exit 1
}

Write-Host "✓ Terraform initialized successfully" -ForegroundColor Green

# Create Terraform plan
Write-Host "`nCreating Terraform plan..." -ForegroundColor Blue
terraform plan -out=tfplan

if (-not $?) {
    Write-Error "Terraform plan creation failed"
    exit 1
}

Write-Host "✓ Terraform plan created successfully" -ForegroundColor Green

# Apply Terraform plan
if ($AutoApprove) {
    Write-Host "`nApplying Terraform plan automatically..." -ForegroundColor Blue
    terraform apply -auto-approve tfplan
}
else {
    $confirm = Read-Host "`nReady to apply the plan? (y/n)"
    
    if ($confirm -eq "y") {
        Write-Host "Applying Terraform plan..." -ForegroundColor Blue
        terraform apply tfplan
    }
    else {
        Write-Host "Deployment canceled by user" -ForegroundColor Yellow
        Stop-Transcript
        exit 0
    }
}

if (-not $?) {
    Write-Error "Terraform apply failed"
    Stop-Transcript
    exit 1
}

# Save outputs to a file
Write-Host "`nSaving Terraform outputs..." -ForegroundColor Blue
terraform output -json | Out-File -FilePath (Join-Path $logDir "terraform-outputs.json")

# Deployment summary
Write-Host "`n======================================================" -ForegroundColor Green
Write-Host " Deployment Complete! " -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Green
Write-Host "Subscription ID: $SubscriptionId"
Write-Host "Resource Group: $ResourceGroup"
Write-Host "Location: $Location"
Write-Host "Environment: $EnvironmentName"
Write-Host "`nOutputs saved to: logs/terraform-outputs.json"
Write-Host "Log file: $logFile"

# Stop logging
Stop-Transcript

Write-Host "`nTo access the Azure Portal, visit: https://portal.azure.com" -ForegroundColor Blue
