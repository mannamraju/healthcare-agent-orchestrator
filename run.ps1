# Healthcare Agent Orchestrator - PowerShell Launcher
# This script provides an interactive menu for deployment operations

# Configuration
$configFile = Join-Path $PSScriptRoot ".hao_config.json"
$logDir = Join-Path $PSScriptRoot "logs"

# Check if log directory exists, create if it doesn't
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}

# Function to load configuration
function Load-Configuration {
    if (Test-Path $configFile) {
        $global:config = Get-Content $configFile | ConvertFrom-Json
        Write-Host "Loaded configuration from $configFile" -ForegroundColor Green
    }
    else {
        $global:config = [PSCustomObject]@{
            SubscriptionId = ""
            ResourceGroup = ""
            Location = "westus"
            EnvironmentName = "dev"
        }
    }
}

# Function to save configuration
function Save-Configuration {
    $global:config | ConvertTo-Json | Out-File -FilePath $configFile -Force
    Write-Host "Configuration saved to $configFile" -ForegroundColor Green
}

# Function to check prerequisites
function Check-Prerequisites {
    # Check Azure CLI
    try {
        $azVersion = az --version
        Write-Host "✓ Azure CLI installed" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Azure CLI not found. Please install it from:" -ForegroundColor Red
        Write-Host "  https://docs.microsoft.com/en-us/cli/azure/install-azure-cli" -ForegroundColor Yellow
        exit
    }
    
    # Check Terraform
    try {
        $tfVersion = terraform --version
        Write-Host "✓ Terraform installed" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Terraform not found. Please install it from:" -ForegroundColor Red
        Write-Host "  https://developer.hashicorp.com/terraform/downloads" -ForegroundColor Yellow
        exit
    }
}

# Function to login to Azure
function Connect-Azure {
    Write-Host "`nLogging in to Azure..." -ForegroundColor Blue
    az login
    
    # Get subscription list
    Write-Host "`nAvailable subscriptions:" -ForegroundColor Blue
    az account list --output table
    
    # Ask for subscription ID if not set
    if ([string]::IsNullOrEmpty($global:config.SubscriptionId)) {
        $global:config.SubscriptionId = Read-Host "Enter subscription ID"
    }
    
    # Set subscription
    az account set --subscription $global:config.SubscriptionId
    Write-Host "Using subscription: $($global:config.SubscriptionId)" -ForegroundColor Green
    
    # Save config
    Save-Configuration
}

# Function to set configuration
function Set-DeploymentConfig {
    Write-Host "`nConfigure Deployment Settings" -ForegroundColor Blue
    
    $input = Read-Host "Subscription ID [$($global:config.SubscriptionId)]"
    if ($input) {
        $global:config.SubscriptionId = $input
    }
    
    $input = Read-Host "Resource Group [$($global:config.ResourceGroup)]"
    if ($input) {
        $global:config.ResourceGroup = $input
    }
    
    $input = Read-Host "Location [$($global:config.Location)]"
    if ($input) {
        $global:config.Location = $input
    }
    
    $input = Read-Host "Environment Name [$($global:config.EnvironmentName)]"
    if ($input) {
        $global:config.EnvironmentName = $input
    }
    
    Save-Configuration
    Write-Host "Configuration updated" -ForegroundColor Green
}

# Function to deploy infrastructure
function Deploy-Infrastructure {
    Write-Host "`nDeploying Infrastructure..." -ForegroundColor Blue
    
    # Check if resource group is set
    if ([string]::IsNullOrEmpty($global:config.ResourceGroup)) {
        $global:config.ResourceGroup = Read-Host "Enter resource group name"
        Save-Configuration
    }
    
    # Check if resource group exists
    $rgExists = az group exists --name $global:config.ResourceGroup
    if ($rgExists -eq "false") {
        Write-Host "Resource group '$($global:config.ResourceGroup)' does not exist. Creating it..." -ForegroundColor Yellow
        az group create --name $global:config.ResourceGroup --location $global:config.Location
    }
    
    # Initialize Terraform
    Write-Host "Initializing Terraform..." -ForegroundColor Blue
    terraform init
    
    # Create Terraform variables file if it doesn't exist
    if (-not (Test-Path "terraform.tfvars")) {
        @"
subscription_id = "$($global:config.SubscriptionId)"
resource_group_name = "$($global:config.ResourceGroup)"
location = "$($global:config.Location)"
environment_name = "$($global:config.EnvironmentName)"
openai_model = "gpt-4o;2024-08-06"
openai_model_capacity = 100
openai_model_sku = "GlobalStandard"
"@ | Out-File -FilePath "terraform.tfvars"
        Write-Host "Created terraform.tfvars with default values" -ForegroundColor Green
    }
    
    # Plan and apply
    Write-Host "Creating Terraform plan..." -ForegroundColor Blue
    terraform plan -out=tfplan
    
    $confirm = Read-Host "Ready to apply the plan? (y/n)"
    if ($confirm -eq "y") {
        Write-Host "Applying Terraform plan..." -ForegroundColor Blue
        terraform apply tfplan
        
        # Save outputs to a file
        terraform output -json | Out-File -FilePath (Join-Path $logDir "terraform-outputs.json")
        Write-Host "Deployment complete. Outputs saved to logs/terraform-outputs.json" -ForegroundColor Green
    }
    else {
        Write-Host "Deployment canceled" -ForegroundColor Yellow
    }
}

# Function to destroy infrastructure
function Remove-Infrastructure {
    Write-Host "`nWARNING: This will destroy all resources in the resource group!" -ForegroundColor Red
    $confirm = Read-Host "Are you sure you want to proceed? (yes/no)"
    
    if ($confirm -ne "yes") {
        Write-Host "Destruction canceled" -ForegroundColor Yellow
        return
    }
    
    Write-Host "Destroying infrastructure..." -ForegroundColor Blue
    terraform destroy
}

# Function to validate deployment
function Test-Deployment {
    Write-Host "`nValidating deployment..." -ForegroundColor Blue
    
    # Check if terraform.tfstate exists
    if (-not (Test-Path "terraform.tfstate")) {
        Write-Host "Terraform state file not found. Have you deployed the infrastructure?" -ForegroundColor Red
        return
    }
    
    # Get resources from state
    Write-Host "Resources deployed:" -ForegroundColor Blue
    terraform state list
    
    # Check key resources
    Write-Host "`nChecking key resources..." -ForegroundColor Blue
    
    $state = terraform state list
    
    if ($state -match "module.ai_services") {
        Write-Host "✓ AI Services deployed" -ForegroundColor Green
    }
    else {
        Write-Host "✗ AI Services not found" -ForegroundColor Red
    }
    
    if ($state -match "module.ai_hub") {
        Write-Host "✓ AI Hub deployed" -ForegroundColor Green
    }
    else {
        Write-Host "✗ AI Hub not found" -ForegroundColor Red
    }
    
    if ($state -match "module.app_service") {
        Write-Host "✓ App Service deployed" -ForegroundColor Green
    }
    else {
        Write-Host "✗ App Service not found" -ForegroundColor Red
    }
    
    if ($state -match "module.bot_services") {
        Write-Host "✓ Bot Services deployed" -ForegroundColor Green
    }
    else {
        Write-Host "✗ Bot Services not found" -ForegroundColor Red
    }
    
    if ($state -match "module.healthcare_agent") {
        Write-Host "✓ Healthcare Agent services deployed" -ForegroundColor Green
    }
    else {
        Write-Host "✗ Healthcare Agent services not found" -ForegroundColor Red
    }
}

# Function to configure Teams integration
function Set-TeamsIntegration {
    Write-Host "`nConfiguring Teams Integration..." -ForegroundColor Blue
    
    # Check if Teams app directory exists
    if (-not (Test-Path (Join-Path $PSScriptRoot "teamsApp"))) {
        Write-Host "Teams app directory not found" -ForegroundColor Red
        return
    }
    
    $chatId = Read-Host "Enter Teams chat ID or meeting link"
    
    # Check if output directory exists
    $outputDir = Join-Path $PSScriptRoot "output"
    if (-not (Test-Path $outputDir)) {
        Write-Host "Output directory not found. Creating it..." -ForegroundColor Yellow
        New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
    }
    
    # Call Teams upload script if it exists
    $uploadScript = Join-Path $PSScriptRoot "scripts\uploadPackage.ps1"
    if (Test-Path $uploadScript) {
        & $uploadScript -directory $outputDir -chatOrMeeting $chatId
    }
    else {
        Write-Host "Teams upload script not found" -ForegroundColor Red
    }
}

# Function to show the main menu
function Show-Menu {
    Clear-Host
    Write-Host "=========================================" -ForegroundColor Blue
    Write-Host " Healthcare Agent Orchestrator - Terraform " -ForegroundColor Blue
    Write-Host "=========================================" -ForegroundColor Blue
    
    Write-Host "`nCurrent Configuration:"
    Write-Host "  Subscription: $($global:config.SubscriptionId)" -ForegroundColor Yellow
    Write-Host "  Resource Group: $($global:config.ResourceGroup)" -ForegroundColor Yellow
    Write-Host "  Location: $($global:config.Location)" -ForegroundColor Yellow
    Write-Host "  Environment: $($global:config.EnvironmentName)" -ForegroundColor Yellow
    
    Write-Host "`n1. Login to Azure" -ForegroundColor Blue
    Write-Host "2. Set Configuration" -ForegroundColor Blue
    Write-Host "3. Deploy Infrastructure" -ForegroundColor Blue
    Write-Host "4. Configure Teams Integration" -ForegroundColor Blue
    Write-Host "5. Validate Deployment" -ForegroundColor Blue
    Write-Host "6. Destroy Infrastructure" -ForegroundColor Blue
    Write-Host "0. Exit" -ForegroundColor Blue
    
    $choice = Read-Host "`nEnter your choice"
    
    switch ($choice) {
        "1" { Connect-Azure }
        "2" { Set-DeploymentConfig }
        "3" { Deploy-Infrastructure }
        "4" { Set-TeamsIntegration }
        "5" { Test-Deployment }
        "6" { Remove-Infrastructure }
        "0" { Write-Host "Goodbye!" -ForegroundColor Green; return }
        default { Write-Host "Invalid choice" -ForegroundColor Red }
    }
    
    Write-Host "`nPress Enter to continue..."
    Read-Host | Out-Null
    Show-Menu
}

# Main execution
Check-Prerequisites
Load-Configuration
Show-Menu
