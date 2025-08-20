#!/bin/bash

# Healthcare Agent Orchestrator - Quick Deploy Script
# This script provides a non-interactive deployment of the Healthcare Agent infrastructure

# ANSI color codes
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
RESET="\033[0m"

# Default values
LOCATION="westus"
ENVIRONMENT_NAME="dev"
AUTO_APPROVE=false
FORCE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -s|--subscription)
      SUBSCRIPTION_ID="$2"
      shift
      shift
      ;;
    -g|--resource-group)
      RESOURCE_GROUP="$2"
      shift
      shift
      ;;
    -l|--location)
      LOCATION="$2"
      shift
      shift
      ;;
    -e|--environment)
      ENVIRONMENT_NAME="$2"
      shift
      shift
      ;;
    -y|--auto-approve)
      AUTO_APPROVE=true
      shift
      ;;
    -f|--force)
      FORCE=true
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [options]"
      echo ""
      echo "Options:"
      echo "  -s, --subscription     Azure Subscription ID"
      echo "  -g, --resource-group   Resource Group name"
      echo "  -l, --location         Azure region (default: westus)"
      echo "  -e, --environment      Environment name (default: dev)"
      echo "  -y, --auto-approve     Skip confirmation prompt"
      echo "  -f, --force            Force redeployment even if resources exist"
      echo "  -h, --help             Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $key"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# Set up logging
LOG_DIR="logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/quick_deploy_$TIMESTAMP.log"

# Start logging
exec > >(tee -a "$LOG_FILE")
exec 2>&1

echo -e "${BLUE}======================================================${RESET}"
echo -e "${BLUE} Healthcare Agent Orchestrator - Quick Deploy ${RESET}"
echo -e "${BLUE}======================================================${RESET}"
echo -e "Log file: ${CYAN}$LOG_FILE${RESET}"

# Check prerequisites
echo -e "\n${BLUE}Checking prerequisites...${RESET}"

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
  echo -e "${RED}✗ jq not found. Please install it${RESET}"
  exit 1
fi

# Login to Azure if not already logged in
echo -e "\n${BLUE}Checking Azure login...${RESET}"
LOGIN_STATUS=$(az account show 2>/dev/null)
LOGIN_STATUS_CODE=$?

if [ $LOGIN_STATUS_CODE -ne 0 ]; then
  echo -e "${YELLOW}Not logged in to Azure. Logging in...${RESET}"
  az login
  
  if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to login to Azure${RESET}"
    exit 1
  fi
else
  echo -e "${GREEN}✓ Already logged in to Azure${RESET}"
fi

# Set subscription if provided
if [ ! -z "$SUBSCRIPTION_ID" ]; then
  echo -e "${BLUE}Setting subscription to: $SUBSCRIPTION_ID${RESET}"
  az account set --subscription "$SUBSCRIPTION_ID"
  
  if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to set subscription${RESET}"
    exit 1
  fi
else
  # Get current subscription
  CURRENT_SUB=$(az account show --query id -o tsv)
  SUBSCRIPTION_ID="$CURRENT_SUB"
  echo -e "${BLUE}Using current subscription: $SUBSCRIPTION_ID${RESET}"
fi

# Check if resource group is provided
if [ -z "$RESOURCE_GROUP" ]; then
  echo -e "${YELLOW}Resource group name is required${RESET}"
  read -p "Enter resource group name: " RESOURCE_GROUP
  
  if [ -z "$RESOURCE_GROUP" ]; then
    echo -e "${RED}Resource group name cannot be empty${RESET}"
    exit 1
  fi
fi

# Check if resource group exists, create if not
RG_EXISTS=$(az group exists --name "$RESOURCE_GROUP")
if [ "$RG_EXISTS" == "false" ]; then
  echo -e "${YELLOW}Resource group '$RESOURCE_GROUP' does not exist. Creating it...${RESET}"
  az group create --name "$RESOURCE_GROUP" --location "$LOCATION"
  
  if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to create resource group${RESET}"
    exit 1
  fi
  
  echo -e "${GREEN}✓ Resource group created${RESET}"
else
  echo -e "${GREEN}✓ Resource group exists${RESET}"
fi

# Create Terraform variables file
echo -e "\n${BLUE}Creating terraform.tfvars file...${RESET}"
cat > terraform.tfvars << EOF
subscription_id = "$SUBSCRIPTION_ID"
resource_group_name = "$RESOURCE_GROUP"
location = "$LOCATION"
environment_name = "$ENVIRONMENT_NAME"
openai_model = "gpt-4o;2024-08-06"
openai_model_capacity = 100
openai_model_sku = "GlobalStandard"
EOF

echo -e "${GREEN}✓ terraform.tfvars created${RESET}"

# Initialize Terraform
echo -e "\n${BLUE}Initializing Terraform...${RESET}"
terraform init

if [ $? -ne 0 ]; then
  echo -e "${RED}Terraform initialization failed${RESET}"
  exit 1
fi

echo -e "${GREEN}✓ Terraform initialized successfully${RESET}"

# Create Terraform plan
echo -e "\n${BLUE}Creating Terraform plan...${RESET}"
terraform plan -out=tfplan

if [ $? -ne 0 ]; then
  echo -e "${RED}Terraform plan creation failed${RESET}"
  exit 1
fi

echo -e "${GREEN}✓ Terraform plan created successfully${RESET}"

# Apply Terraform plan
if [ "$AUTO_APPROVE" = true ]; then
  echo -e "\n${BLUE}Applying Terraform plan automatically...${RESET}"
  terraform apply -auto-approve tfplan
else
  read -p $'\nReady to apply the plan? (y/n): ' CONFIRM
  
  if [ "$CONFIRM" = "y" ]; then
    echo -e "${BLUE}Applying Terraform plan...${RESET}"
    terraform apply tfplan
  else
    echo -e "${YELLOW}Deployment canceled by user${RESET}"
    exit 0
  fi
fi

if [ $? -ne 0 ]; then
  echo -e "${RED}Terraform apply failed${RESET}"
  exit 1
fi

# Save outputs to a file
echo -e "\n${BLUE}Saving Terraform outputs...${RESET}"
terraform output -json > "$LOG_DIR/terraform-outputs.json"

# Deployment summary
echo -e "\n${GREEN}======================================================${RESET}"
echo -e "${GREEN} Deployment Complete! ${RESET}"
echo -e "${GREEN}======================================================${RESET}"
echo -e "Subscription ID: ${CYAN}$SUBSCRIPTION_ID${RESET}"
echo -e "Resource Group: ${CYAN}$RESOURCE_GROUP${RESET}"
echo -e "Location: ${CYAN}$LOCATION${RESET}"
echo -e "Environment: ${CYAN}$ENVIRONMENT_NAME${RESET}"
echo -e "\nOutputs saved to: ${CYAN}logs/terraform-outputs.json${RESET}"
echo -e "Log file: ${CYAN}$LOG_FILE${RESET}"

echo -e "\n${BLUE}To access the Azure Portal, visit: https://portal.azure.com${RESET}"
