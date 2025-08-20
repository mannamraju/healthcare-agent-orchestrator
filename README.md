# Healthcare Agent Orchestrator (Terraform Edition)

Healthcare Agent Orchestrator is a multi-agent accelerator that coordinates modular specialized agents across diverse data types and tools like M365 and Teams to assist multi-disciplinary healthcare workflows—such as cancer care. This Terraform implementation provides Infrastructure as Code deployment for consistent, reproducible environments.

> [!IMPORTANT]
> Healthcare Agent Orchestrator is a code sample to help you build an agent intended for research and development use only. Healthcare Agent Orchestrator is not designed or intended to be deployed in clinical settings as-is nor is it intended for use in the diagnosis or treatment of any health or medical condition, and its performance for such purposes has not been established. By using the Healthcare Agent Orchestrator sample, you are acknowledging that you bear sole responsibility and liability for any use of Healthcare Agent Orchestrator.

## Features

- **Terraform-based Infrastructure as Code**: Deploy consistent, version-controlled environments
- **Multi-agent orchestration**: Coordinate specialized healthcare agents for complex workflows
- **GPU-optimized deployments**: Support for Azure GPU resources for advanced healthcare AI models
- **Teams integration**: Seamless integration with Microsoft Teams for collaborative workflows
- **Healthcare AI models**: Integration with Azure AI models like CxrReportGen
- **Modular architecture**: Easily add or modify agents to meet specific healthcare needs
- **Security-focused**: Follows Microsoft security best practices with managed identities and RBAC
- **Data integration**: Support for multiple data sources including BLOB storage and FHIR

## Solution Architecture

The Healthcare Agent Orchestrator deploys the following components:

- Azure OpenAI Service with GPT-4o/GPT-4.1 models
- Azure Bot Service instances for each specialized agent
- Azure App Service for the backend
- Key Vault for secure secret management
- Storage Accounts for patient data and application state
- AI Hub for model orchestration
- Virtual Network with security configurations
- Healthcare Agent services for specialized healthcare capabilities

## Quick Start Guide

The Healthcare Agent Orchestrator provides several convenient scripts to simplify deployment and management:

### Deployment Scripts

- **run.sh / run.ps1**: Main launcher scripts that provide an interactive menu for all operations
- **quick_deploy.sh / quick_deploy.ps1 / quick_deploy.cmd**: Fast deployment with minimal prompts

### Prerequisites

- An Azure subscription with:
  - Azure OpenAI: 100k Tokens per Minute quota for GPT-4o or GPT-4.1
  - GPU resources (NCADSA100v4 Family or NCADSH100v5 Family)
  - A resource group where you have _Owner_ permissions
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Terraform](https://developer.hashicorp.com/terraform/downloads) (1.0.0 or later)
- PowerShell (for Windows) or Bash (for Linux/macOS)

### Deployment Tools and Scripts

The repository includes several deployment scripts designed to simplify the deployment process:

#### Interactive Launcher Scripts (`run.sh` / `run.ps1`)

These scripts provide a comprehensive menu-driven interface for all operations:

- **Prerequisites checking**: Verifies Azure CLI and Terraform are installed
- **Configuration management**: Save/load deployment settings between sessions
- **Azure login**: Simplified authentication and subscription selection
- **Infrastructure deployment**: Step-by-step guided deployment process
- **Validation tools**: Verify that all components deployed successfully
- **Teams integration**: Configure Teams integration with deployed resources
- **Clean-up utilities**: Remove deployed resources when no longer needed

#### Quick Deploy Scripts (`quick_deploy.sh` / `quick_deploy.ps1`)

For fast, minimal-interaction deployments:

- **Command-line parameters**: Pass all configuration via parameters
- **Auto-approval option**: Run without interactive prompts
- **Detailed logging**: All operations are logged to timestamped files
- **Error handling**: Comprehensive error detection and reporting
- **Summary output**: Deployment summary with key resource information

### Deployment Options

#### 1. Using Quick Deploy Scripts

For the fastest deployment with minimal configuration:

**Windows (PowerShell)**:

```powershell
.\quick_deploy.ps1 -SubscriptionId "your-subscription-id" -ResourceGroup "your-resource-group" -Location "westus"
```

**Linux/macOS (Bash)**:

```bash
./quick_deploy.sh -s "your-subscription-id" -g "your-resource-group" -l "westus"
```

Full parameters for quick deploy scripts:

| Parameter | Short | Description | Default |
|-----------|-------|-------------|---------|
| SubscriptionId / --subscription | -s | Azure Subscription ID | Current |
| ResourceGroup / --resource-group | -g | Resource Group name | Required |
| Location / --location | -l | Azure region | westus |
| EnvironmentName / --environment | -e | Environment name | dev |
| AutoApprove / --auto-approve | -y | Skip confirmation prompt | false |
| Force / --force | -f | Force redeployment | false |

#### 2. Using Interactive Launcher

For guided, interactive deployment:

**Windows (PowerShell)**:

```powershell
.\run.ps1
```

**Linux/macOS (Bash)**:

```bash
./run.sh
```

Follow the interactive menu to:

1. Log in to Azure
2. Set configuration options
3. Deploy infrastructure
4. Configure Teams integration
5. Validate deployment

#### 3. Manual Terraform Deployment

For full control over the deployment process:

```bash
# Login to Azure CLI
az login

# Initialize Terraform
terraform init

# Create execution plan
terraform plan -out=tfplan

# Apply the plan
terraform apply tfplan
```

## AI Agent Role Summaries

- **Orchestrator**: Facilitates conversation between users and expert agents
- **Patient History**: Loads and presents patient clinical timelines
- **Radiology**: Analyzes chest x-ray images using CXRReportGen model
- **Patient Status**: Provides structured summaries of patient clinical status
- **Clinical Guidelines**: Generates treatment plans based on clinical guidelines
- **Report Creation**: Compiles comprehensive tumor board documentation
- **Clinical Trials**: Searches for relevant trials based on patient characteristics
- **Medical Research**: Retrieves research-backed insights using Microsoft GraphRAG

## Configuration

Key configuration is managed through `terraform.tfvars` and environment variables:

```terraform
# Example terraform.tfvars
subscription_id              = "your-subscription-id"
resource_group_name          = "your-resource-group"
environment_name             = "dev"
location                     = "westus"
healthcare_agent_service_location = "westus"
openai_model                 = "gpt-4o;2024-08-06"
openai_model_capacity        = 100
openai_model_sku             = "GlobalStandard"
```

## Directory Structure

```
├── tf_modules/                # Terraform modules for each component
│   ├── ai-hub/                # AI Hub configuration
│   ├── ai-services/           # AI Services setup
│   ├── app-service/           # App Service configuration
│   ├── bot-service/           # Bot Service setup
│   ├── healthcare-agent-module/ # Healthcare agent implementation
│   ├── key-vault/             # Key Vault configuration
│   └── ...
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Variable definitions
├── terraform.tfvars           # Variable values
├── run.sh / run.ps1           # Interactive launcher scripts
└── quick_deploy.sh / quick_deploy.ps1 # Quick deployment scripts
```

## Advanced Configuration

### GPU Optimization

For GPU-optimized deployments, configure the appropriate GPU instance type in your variables:

```terraform
instance_type = "Standard_NC24ads_A100_v4" # or "Standard_NC40ads_H100_v5"
```

Refer to `GPU_USAGE_GUIDE.md` for detailed GPU optimization tips.

### Network Security

The deployment includes network security configurations with:
- Virtual Network with defined subnets
- Network Security Groups for controlled access
- Key Vault with network restrictions
- App Service with IP restrictions

## Troubleshooting

Common issues and solutions:

- **Quota limitations**: Ensure you have sufficient quota for Azure OpenAI and GPU resources
- **Permission errors**: Verify you have Owner permissions on the resource group
- **Deployment failures**: Check logs in the `logs/` directory for detailed error messages
- **Teams integration issues**: Ensure your tenant allows custom Teams app installation

## Resources and Documentation

- [User Guide](./docs/user_guide.md)
- [Agent Development Guide](./docs/agent_development.md)
- [Healthcare Scenarios Guide](./docs/scenarios.md)
- [Data Ingestion Guide](./docs/data_ingestion.md)
- [Network Architecture](./docs/network.md)
- [Teams Integration Guide](./docs/teams.md)

## Ethical Considerations

Microsoft believes Responsible AI is a shared responsibility and we have identified six principles and practices that help organizations address risks, innovate, and create value: fairness, reliability and safety, privacy and security, inclusiveness, transparency, and accountability.

Please see Microsoft''s [Responsible AI Principles](https://www.microsoft.com/en-us/ai/principles-and-approach/).

## Contact and Support

For questions or inquiries, please contact us at hlsfrontierteam@microsoft.com

If you encounter issues, please create a [GitHub issue](https://github.com/mannamraju/healthcare-agent-orchestrator/issues) with details about the problem and steps to reproduce it.

## Contributing

We welcome contributions to improve this project! Please see our [Contribution Guide](./CONTRIBUTING.md) for information on how to get started.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
