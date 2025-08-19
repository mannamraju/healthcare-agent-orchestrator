# Healthcare Agent Orchestrator - Directory Consolidation

## Directory Structure Changes

The repository has been reorganized to improve clarity and reduce redundancy:

### Module Structure

All Terraform modules are now consolidated under the modules/ directory:
- modules/ai-hub - AI Hub services
- modules/ai-services - Azure AI services
- modules/healthcare-agent-service - Healthcare Agent specific services
- modules/core-infrastructure - Core infrastructure components

### Deployment Options

The following deployment options remain available:
- comprehensive_deployment/ - Full Healthcare Agent deployment
- simplified_deployment/ - Simplified Healthcare Agent deployment

### Script Organization

- scripts/ - PowerShell scripts
- ash/ - Bash scripts
- 	ools/ - Repository maintenance tools

### Backups

Original directories were backed up to:
- ackups/ - Contains copies of all consolidated directories

## Note on .old Directories

Directories with the .old suffix are the original directories before consolidation.
They can be safely removed once you've verified the consolidation was successful.

To remove them, run:

`powershell
Get-ChildItem -Path . -Directory -Filter "*.old" | Remove-Item -Recurse -Force
`
