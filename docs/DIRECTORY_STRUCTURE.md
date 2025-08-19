# Healthcare Agent Orchestrator - Directory Structure

After organizing the scripts, the Healthcare Agent Orchestrator project structure will look as follows:

```plaintext
HAO-TF/
│
├── scripts/                     # Contains all PowerShell scripts
│   ├── README.md                # Documentation for scripts
│   ├── launcher.ps1             # Main script launcher with menu interface
│   ├── deploy_comprehensive.ps1 # Standard deployment script
│   ├── deploy_end_to_end.ps1    # End-to-end deployment with validation
│   ├── monitor_comprehensive.ps1 # Monitor deployment progress
│   ├── health_check_comprehensive.ps1 # Health check script
│   ├── validate_comprehensive.ps1 # Validation script
│   ├── fresh_start.ps1         # Cleanup script
│   ├── initialize_providers.ps1 # Provider initialization script
│   └── organize_scripts.ps1     # Script organization tool
│
├── run.ps1                      # Entry point script (redirects to launcher.ps1)
├── deploy_comprehensive.ps1     # Wrapper (redirects to scripts/deploy_comprehensive.ps1)
├── deploy_end_to_end.ps1        # Wrapper (redirects to scripts/deploy_end_to_end.ps1)
├── monitor_comprehensive.ps1    # Wrapper (redirects to scripts/monitor_comprehensive.ps1)
├── health_check_comprehensive.ps1 # Wrapper (redirects to scripts/health_check_comprehensive.ps1)
├── validate_comprehensive.ps1   # Wrapper (redirects to scripts/validate_comprehensive.ps1)
│
├── comprehensive_deployment/    # Comprehensive deployment resources
│   ├── main.tf                  # Main Terraform configuration
│   ├── variables.tf             # Variable definitions
│   ├── outputs.tf               # Output definitions
│   └── modules/                 # Terraform modules
│
├── simplified_deployment/       # Simplified deployment resources
│   ├── main.tf                  # Main Terraform configuration
│   ├── variables.tf             # Variable definitions
│   └── outputs.tf               # Output definitions
│
├── logs/                        # Deployment and execution logs
│
└── SCRIPT_REFERENCE.md          # Guide to all scripts and their purposes
```

## How to Use

1. **Main Entry Point**: Run `.\run.ps1` from the root directory to access the script launcher menu.

2. **Backward Compatibility**: All major scripts have wrappers in the root directory for backward compatibility. These simply redirect to the corresponding script in the `scripts` folder.

3. **Direct Access**: You can directly run scripts from the `scripts` folder if preferred:

   ```powershell
   .\scripts\deploy_comprehensive.ps1 -SubscriptionId "your-id" -ResourceGroup "your-rg" -EnvironmentName "dev"
   ```

4. **Script Documentation**: Refer to `SCRIPT_REFERENCE.md` for detailed information about each script's purpose and usage.

## Benefits of This Structure

1. **Cleaner Root Directory**: The root directory is no longer cluttered with numerous scripts
2. **Better Organization**: All scripts are centralized in the `scripts` folder
3. **Easier Maintenance**: Scripts can be updated in one place
4. **Backward Compatibility**: Existing workflows continue to work through wrapper scripts
5. **Clear Documentation**: README and reference guide explain the purpose of each script
