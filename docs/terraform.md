# Terraform Deployment

Switching to Terraform will use configuration at the repository root (e.g., `main.tf`, `variables.tf`, modules under `tf_modules/`).

## How to Switch Deployment Provider to Terraform

1. Open the root file `azure.yaml`.
2. Find (or add) the `infra` block.
3. Set the `provider` value:

```yaml
   infra:
     provider: terraform  # Uses main.tf and tf_modules/
     path: .
```

4. Save the file.

## Tooling Requirements

- Terraform: Install Terraform CLI (v1.5+ recommended)

> [!TIP]
> If you switch from Terraform back to Bicep (or vice versa), consider cleaning previous state artifacts (`.terraform/`, `terraform.tfstate*`) to avoid confusion. For Terraform-managed deployments, destroying (`terraform destroy` or `azd down --purge`) before switching helps keep resource state consistent.

## Variables

When using Terraform with `azd`, variables are configured through `main.tfvars.json`.

Copy `main.tfvars.json.example` to `main.tfvars.json` and update values as necessary.

> [!NOTE]
> Unlike Bicep deployments, regular azd env variables are not automatically passed to Terraform. Use the method above to ensure your variables are properly configured.

## Deployment

Continue to follow the guidance in the [README.md](../README.md) for using `azd` to deploy, including creating the environment.
