# Steps to Deploy AI Hub

This document outlines the steps required to deploy the AI Hub for the Healthcare Agent Orchestrator.

## Prerequisites

- Azure subscription with permissions to create resources
- Terraform CLI installed
- Azure CLI installed and authenticated

## Deployment Steps

1. Navigate to the AI Hub directory:

   ```
   cd c:\Users\mannamraju\localCode\HAO-TF\ai-hub
   ```

2. Initialize Terraform:

   ```
   terraform init
   ```

3. Validate the Terraform configuration:

   ```
   terraform validate
   ```

4. Create a Terraform plan:

   ```
   terraform plan -var-file=ai-hub.tfvars -out=ai-hub.plan
   ```

5. Apply the Terraform plan to deploy the AI Hub:

   ```
   terraform apply "ai-hub.plan"
   ```

## Verification

After deployment, verify the following:

1. The AI Hub resource has been created in the Azure portal
2. The AI Project has been created and linked to the AI Hub
3. The AI Hub is properly connected to the OpenAI service
4. All role assignments have been properly set up

## Troubleshooting

If you encounter any issues during deployment:

1. Check the Terraform logs for error messages
2. Verify that the resource group and other referenced resources exist
3. Ensure the service principal has sufficient permissions
4. Check if there are any Azure resource constraints or quota limits

## Cleanup

To remove the deployed resources:

```
terraform destroy -var-file=ai-hub.tfvars
```

Note: This will only remove the AI Hub resources created by this specific deployment.
