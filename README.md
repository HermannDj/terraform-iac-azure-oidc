# terraform-iac-azure-oidc

Terraform Infrastructure as Code for Azure with OIDC Authentication

## Overview

This repository contains Terraform configuration for deploying Azure infrastructure using OpenID Connect (OIDC) authentication from GitHub Actions. The setup includes:

- Azure Container Registry (ACR)
- Azure App Service Plan
- Azure Linux Web App

## State Lock Handling

This configuration includes safeguards against Terraform state lock issues:

### Lock Timeout Configuration

Both `terraform plan` and `terraform apply` commands use `-lock-timeout=5m` flag, which:
- Waits up to 5 minutes for an existing lock to be released
- Automatically retries acquiring the lock during that period
- Prevents immediate failure when encountering a locked state

### Job Timeouts

All Terraform operations have timeout limits to prevent indefinite runs:
- `terraform init`: 5 minutes
- `terraform plan`: 10 minutes
- `terraform apply`: 30 minutes

### Manual Unlock

If a lock persists and manual intervention is needed, the workflow provides clear instructions. To manually unlock:

```bash
terraform force-unlock <LOCK_ID>
```

The LOCK_ID can be found in the error output of the failed workflow run.

## Authentication

The workflow uses OIDC authentication with Azure, configured through environment variables:
- `ARM_CLIENT_ID` - Azure AD Application (client) ID
- `ARM_TENANT_ID` - Azure AD Tenant ID
- `ARM_SUBSCRIPTION_ID` - Azure Subscription ID

These are set automatically by the GitHub Actions workflow based on repository variables.

## Infrastructure Components

### Resources Created

1. **Resource Group** - Container for all Azure resources
2. **Container Registry** - For storing Docker images
3. **Service Plan** - Linux-based App Service Plan (B1 tier)
4. **Web App** - Linux Web App connected to the Container Registry

### Backend Configuration

State is stored in Azure Blob Storage:
- Resource Group: `tfstate-backend-rg`
- Storage Account: `tfstatebackendhermann`
- Container: `terraform-tfstate`
- State File: `terraform.tfstate`

## Usage

The Terraform pipeline runs automatically on:
- Pull requests to `main` branch (plan only)
- Pushes to `main` branch (plan + apply)

### Required Variables

Configure these as repository variables in GitHub:
- `AZURE_CLIENT_ID_PULL_REQUEST` - Client ID for PR runs
- `AZURE_CLIENT_ID_MAIN` - Client ID for main branch runs
- `AZURE_TENANT_ID` - Azure AD tenant ID
- `AZURE_SUBSCRIPTION_ID` - Azure subscription ID
- `TF_RESOURCE_GROUP_NAME` - Name for the resource group
- `TF_ACR_NAME` - Name for the Container Registry
- `TF_APP_SERVICE_PLAN_NAME` - Name for the App Service Plan
- `TF_APP_SERVICE_NAME` - Name for the Web App
- `TF_LOCATION` - Azure region (e.g., "Canada Central")

## Local Development

To work with this Terraform configuration locally:

1. Ensure you have Terraform installed
2. Configure Azure authentication (az login or environment variables)
3. Navigate to the `terraform` directory
4. Run:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Troubleshooting

### State Lock Issues

If you encounter a state lock error:

1. **Wait and retry** - Locks typically expire after 10 minutes
2. **Check for running workflows** - Ensure no other workflow is currently running
3. **Manual unlock** - If needed, use the lock ID from the error message:
   ```bash
   cd terraform
   terraform force-unlock <LOCK_ID>
   ```

### Authentication Issues

Ensure:
- The Azure AD application has proper permissions
- Federated credentials are configured correctly for OIDC
- Repository variables are set with correct values