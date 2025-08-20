#!/bin/bash

# Healthcare Agent Orchestrator - Bash Launcher
# This script provides an interactive menu for deployment operations

# ANSI color codes
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
RESET="\033[0m"

# Configuration
CONFIG_FILE=".hao_config.json"
LOG_DIR="logs"

# Check if log directory exists, create if it doesn't
if [ ! -d "$LOG_DIR" ]; then
  mkdir -p "$LOG_DIR"
fi

# Function to load configuration
load_configuration() {
  if [ -f "$CONFIG_FILE" ]; then
    echo -e "${GREEN}Loading configuration from $CONFIG_FILE${RESET}"
    SUBSCRIPTION_ID=$(jq -r '.subscriptionId // ""' "$CONFIG_FILE")
    RESOURCE_GROUP=$(jq -r '.resourceGroup // ""' "$CONFIG_FILE")
    LOCATION=$(jq -r '.location // "westus"' "$CONFIG_FILE")
    ENVIRONMENT_NAME=$(jq -r '.environmentName // "dev"' "$CONFIG_FILE")
  else
    echo -e "${YELLOW}No configuration found. Creating default configuration.${RESET}"
    SUBSCRIPTION_ID=""
    RESOURCE_GROUP=""
    LOCATION="westus"
    ENVIRONMENT_NAME="dev"
    save_configuration
  fi
}

# Function to save configuration
save_configuration() {
  echo -e "${GREEN}Saving configuration to $CONFIG_FILE${RESET}"
  echo "{
  \"subscriptionId\": \"$SUBSCRIPTION_ID\",
  \"resourceGroup\": \"$RESOURCE_GROUP\",
  \"location\": \"$LOCATION\",
  \"environmentName\": \"$ENVIRONMENT_NAME\"
}" > "$CONFIG_FILE"
}

# Function to check prerequisites
check_prerequisites() {
  echo -e "${BLUE}Checking prerequisites...${RESET}"
  
  # Check Azure CLI
  if command -v az &> /dev/null; then
    echo -e "${GREEN}✓ Azure CLI installed${RESET}"
  else
    echo -e "${RED}✗ Azure CLI not found. Please install it from:${RESET}"
    echo -e "${YELLOW}  https://docs.microsoft.com/en-us/cli/azure/install-azure-cli${RESET}"
    exit 1
  fi
  
  # Check Terraform
  if command -v terraform &> /dev/null; then
    echo -e "${GREEN}✓ Terraform installed${RESET}"
  else
    echo -e "${RED}✗ Terraform not found. Please install it from:${RESET}"
    echo -e "${YELLOW}  https://developer.hashicorp.com/terraform/downloads${RESET}"
    exit 1
  fi
  
  # Check jq
  if command -v jq &> /dev/null; then
    echo -e "${GREEN}✓ jq installed${RESET}"
  else
    echo -e "${RED}✗ jq not found. Please install it:${RESET}"
    echo -e "${YELLOW}  On Ubuntu/Debian: sudo apt-get install jq${RESET}"
    echo -e "${YELLOW}  On macOS: brew install jq${RESET}"
    exit 1
  fi
}

# Function to login to Azure
connect_azure() {
  echo -e "\n${BLUE}Logging in to Azure...${RESET}"
  az login
  
  # Get subscription list
  echo -e "\n${BLUE}Available subscriptions:${RESET}"
  az account list --output table
  
  # Ask for subscription ID if not set
  if [ -z "$SUBSCRIPTION_ID" ]; then
    read -p "Enter subscription ID: " SUBSCRIPTION_ID
  fi
  
  # Set subscription
  az account set --subscription "$SUBSCRIPTION_ID"
  echo -e "${GREEN}Using subscription: $SUBSCRIPTION_ID${RESET}"
  
  # Save config
  save_configuration
}

# Function to set configuration
set_deployment_config() {
  echo -e "\n${BLUE}Configure Deployment Settings${RESET}"
  
  read -p "Subscription ID [$SUBSCRIPTION_ID]: " INPUT
  if [ ! -z "$INPUT" ]; then
    SUBSCRIPTION_ID="$INPUT"
  fi
  
  read -p "Resource Group [$RESOURCE_GROUP]: " INPUT
  if [ ! -z "$INPUT" ]; then
    RESOURCE_GROUP="$INPUT"
  fi
  
  read -p "Location [$LOCATION]: " INPUT
  if [ ! -z "$INPUT" ]; then
    LOCATION="$INPUT"
  fi
  
  read -p "Environment Name [$ENVIRONMENT_NAME]: " INPUT
  if [ ! -z "$INPUT" ]; then
    ENVIRONMENT_NAME="$INPUT"
  fi
  
  save_configuration
  echo -e "${GREEN}Configuration updated${RESET}"
}

# Function to deploy infrastructure
deploy_infrastructure() {
  echo -e "\n${BLUE}Deploying Infrastructure...${RESET}"
  
  # Check if resource group is set
  if [ -z "$RESOURCE_GROUP" ]; then
    read -p "Enter resource group name: " RESOURCE_GROUP
    save_configuration
  fi
  
  # Check if resource group exists
  RG_EXISTS=$(az group exists --name "$RESOURCE_GROUP")
  if [ "$RG_EXISTS" == "false" ]; then
    echo -e "${YELLOW}Resource group '$RESOURCE_GROUP' does not exist. Creating it...${RESET}"
    az group create --name "$RESOURCE_GROUP" --location "$LOCATION"
  fi
  
  # Initialize Terraform
  echo -e "${BLUE}Initializing Terraform...${RESET}"
  terraform init
  
  # Create Terraform variables file if it doesn't exist
  if [ ! -f "terraform.tfvars" ]; then
    echo -e "${BLUE}Creating terraform.tfvars file...${RESET}"
    cat > terraform.tfvars << EOF
subscription_id = "$SUBSCRIPTION_ID"
resource_group_name = "$RESOURCE_GROUP"
location = "$LOCATION"
environment_name = "$ENVIRONMENT_NAME"
openai_model = "gpt-4o;2024-08-06"
openai_model_capacity = 100
openai_model_sku = "GlobalStandard"
EOF
    echo -e "${GREEN}Created terraform.tfvars with default values${RESET}"
  fi
  
  # Plan and apply
  echo -e "${BLUE}Creating Terraform plan...${RESET}"
  terraform plan -out=tfplan
  
  read -p "Ready to apply the plan? (y/n): " CONFIRM
  if [ "$CONFIRM" == "y" ]; then
    echo -e "${BLUE}Applying Terraform plan...${RESET}"
    terraform apply tfplan
    
    # Save outputs to a file
    terraform output -json > "$LOG_DIR/terraform-outputs.json"
    echo -e "${GREEN}Deployment complete. Outputs saved to logs/terraform-outputs.json${RESET}"
  else
    echo -e "${YELLOW}Deployment canceled${RESET}"
  fi
}

# Function to destroy infrastructure
remove_infrastructure() {
  echo -e "\n${RED}WARNING: This will destroy all resources in the resource group!${RESET}"
  read -p "Are you sure you want to proceed? (yes/no): " CONFIRM
  
  if [ "$CONFIRM" != "yes" ]; then
    echo -e "${YELLOW}Destruction canceled${RESET}"
    return
  fi
  
  echo -e "${BLUE}Destroying infrastructure...${RESET}"
  terraform destroy
}

# Function to validate deployment
test_deployment() {
  echo -e "\n${BLUE}Validating deployment...${RESET}"
  
  # Check if terraform.tfstate exists
  if [ ! -f "terraform.tfstate" ]; then
    echo -e "${RED}Terraform state file not found. Have you deployed the infrastructure?${RESET}"
    return
  fi
  
  # Get resources from state
  echo -e "${BLUE}Resources deployed:${RESET}"
  terraform state list
  
  # Check key resources
  echo -e "\n${BLUE}Checking key resources...${RESET}"
  
  STATE=$(terraform state list)
  
  if echo "$STATE" | grep -q "module.ai_services"; then
    echo -e "${GREEN}✓ AI Services deployed${RESET}"
  else
    echo -e "${RED}✗ AI Services not found${RESET}"
  fi
  
  if echo "$STATE" | grep -q "module.ai_hub"; then
    echo -e "${GREEN}✓ AI Hub deployed${RESET}"
  else
    echo -e "${RED}✗ AI Hub not found${RESET}"
  fi
  
  if echo "$STATE" | grep -q "module.app_service"; then
    echo -e "${GREEN}✓ App Service deployed${RESET}"
  else
    echo -e "${RED}✗ App Service not found${RESET}"
  fi
  
  if echo "$STATE" | grep -q "module.bot_services"; then
    echo -e "${GREEN}✓ Bot Services deployed${RESET}"
  else
    echo -e "${RED}✗ Bot Services not found${RESET}"
  fi
  
  if echo "$STATE" | grep -q "module.healthcare_agent"; then
    echo -e "${GREEN}✓ Healthcare Agent services deployed${RESET}"
  else
    echo -e "${RED}✗ Healthcare Agent services not found${RESET}"
  fi
}

# Function to configure Teams integration
set_teams_integration() {
  echo -e "\n${BLUE}Configuring Teams Integration...${RESET}"
  
  # Check if Teams app directory exists
  if [ ! -d "teamsApp" ]; then
    echo -e "${RED}Teams app directory not found${RESET}"
    return
  fi
  
  read -p "Enter Teams chat ID or meeting link: " CHAT_ID
  
  # Check if output directory exists
  OUTPUT_DIR="output"
  if [ ! -d "$OUTPUT_DIR" ]; then
    echo -e "${YELLOW}Output directory not found. Creating it...${RESET}"
    mkdir -p "$OUTPUT_DIR"
  fi
  
  # Call Teams upload script if it exists
  UPLOAD_SCRIPT="scripts/uploadPackage.sh"
  if [ -f "$UPLOAD_SCRIPT" ]; then
    bash "$UPLOAD_SCRIPT" -d "$OUTPUT_DIR" -c "$CHAT_ID"
  else
    echo -e "${RED}Teams upload script not found${RESET}"
  fi
}

# Function to show the main menu
show_menu() {
  clear
  echo -e "${BLUE}==========================================${RESET}"
  echo -e "${BLUE} Healthcare Agent Orchestrator - Terraform ${RESET}"
  echo -e "${BLUE}==========================================${RESET}"
  
  echo -e "\nCurrent Configuration:"
  echo -e "  Subscription: ${YELLOW}$SUBSCRIPTION_ID${RESET}"
  echo -e "  Resource Group: ${YELLOW}$RESOURCE_GROUP${RESET}"
  echo -e "  Location: ${YELLOW}$LOCATION${RESET}"
  echo -e "  Environment: ${YELLOW}$ENVIRONMENT_NAME${RESET}"
  
  echo -e "\n${BLUE}1. Login to Azure${RESET}"
  echo -e "${BLUE}2. Set Configuration${RESET}"
  echo -e "${BLUE}3. Deploy Infrastructure${RESET}"
  echo -e "${BLUE}4. Configure Teams Integration${RESET}"
  echo -e "${BLUE}5. Validate Deployment${RESET}"
  echo -e "${BLUE}6. Destroy Infrastructure${RESET}"
  echo -e "${BLUE}0. Exit${RESET}"
  
  read -p $'\nEnter your choice: ' CHOICE
  
  case $CHOICE in
    1) connect_azure ;;
    2) set_deployment_config ;;
    3) deploy_infrastructure ;;
    4) set_teams_integration ;;
    5) test_deployment ;;
    6) remove_infrastructure ;;
    0) echo -e "${GREEN}Goodbye!${RESET}"; exit 0 ;;
    *) echo -e "${RED}Invalid choice${RESET}" ;;
  esac
  
  echo -e "\nPress Enter to continue..."
  read
  show_menu
}

# Main execution
check_prerequisites
load_configuration
show_menu
