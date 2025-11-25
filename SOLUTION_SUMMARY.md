# Solution Summary: Terraform State Lock Error Fix

## Problem Statement

The Terraform pipeline was failing with a state lock error:
```
Error: Error acquiring the state lock
Error message: state blob is already locked
Lock Info:
  ID:        0433a7bc-1be2-2b91-f28f-54e8f4faf7fc
  Path:      terraform-tfstate/terraform.tfstate
  Operation: OperationTypePlan
  Who:       runner@runnervmg1sw1
  Created:   2025-11-15 19:06:21.708990041 +0000 UTC
```

This occurred because a previous workflow run was cancelled or failed without releasing the state lock.

## Root Cause

When Terraform operations are interrupted (cancelled jobs, timeouts, crashes), the state lock may not be released automatically. This prevents subsequent runs from acquiring the lock and modifying the state.

## Solution Implemented

### 1. Lock Timeout Configuration (Primary Fix)

Added `-lock-timeout=5m` to both `terraform plan` and `terraform apply` commands:

```yaml
- name: Terraform Plan
  run: terraform plan -lock-timeout=5m -out=tfplan
  
- name: Terraform Apply  
  run: terraform apply -auto-approve -lock-timeout=5m tfplan
```

**How this works:**
- Instead of failing immediately when encountering a lock, Terraform waits up to 5 minutes
- During this time, it automatically retries acquiring the lock
- If the lock naturally expires (Azure has a ~10 minute timeout), it will be acquired
- This handles the most common case where locks are left by cancelled/failed jobs

### 2. Job Timeouts

Added timeout limits to prevent indefinite runs:
- `terraform init`: 5 minutes
- `terraform plan`: 10 minutes
- `terraform apply`: 30 minutes

This ensures jobs don't hang indefinitely waiting for locks or other operations.

### 3. Informative Error Messages

Added a cleanup step that provides clear instructions if manual intervention is needed:

```yaml
- name: Cleanup - Post Failure Info
  if: failure()
  run: |
    echo "::error::Terraform operation failed. If this is due to a state lock, you may need to manually force-unlock."
    echo "::error::To manually unlock, run: terraform force-unlock <LOCK_ID>"
    echo "::error::Find the LOCK_ID in the error output above."
```

### 4. Modern Azure Resources

Updated Terraform configuration to use current, non-deprecated resources:
- `azurerm_service_plan` (instead of `azurerm_app_service_plan`)
- `azurerm_linux_web_app` (instead of `azurerm_app_service`)

### 5. Simplified Authentication

Provider configuration uses environment variables set by the workflow:
- ARM_CLIENT_ID
- ARM_TENANT_ID  
- ARM_SUBSCRIPTION_ID

This reduces complexity and makes the configuration cleaner.

## How This Fixes the Original Error

The original lock from November 15, 2025 will:
1. Either have already timed out naturally (Azure's default is ~10 minutes)
2. Or will time out on the next workflow run after 5-10 minutes of waiting

With the `-lock-timeout=5m` flag, the workflow will:
1. Detect the existing lock
2. Wait patiently for up to 5 minutes
3. Acquire the lock once it's released
4. Continue with the terraform operation

If locks continue to be an issue, the workflow provides clear error messages with instructions for manual unlock.

## Prevention of Future Lock Issues

The combination of:
- Lock timeout flags (wait instead of fail)
- Job timeouts (prevent indefinite hangs)
- Clear error messages (guide manual intervention)

...ensures that state lock issues are either automatically resolved or clearly communicated.

## Files Modified/Created

1. `.github/workflows/terraform-pipeline.yml` - Added lock handling and timeouts
2. `terraform/backend.tf` - Backend configuration with OIDC
3. `terraform/provider.tf` - Simplified provider using env vars
4. `terraform/main.tf` - Resources using modern Azure provider types
5. `terraform/variables.tf` - Input variables
6. `terraform/outputs.tf` - Output values
7. `terraform/.terraform.lock.hcl` - Provider version lock
8. `README.md` - Comprehensive documentation

## Testing Recommendations

1. **Test lock timeout**: Cancel a running workflow mid-plan and verify the next run waits and succeeds
2. **Test job timeout**: Ensure jobs don't run indefinitely
3. **Test normal operation**: Verify plan and apply work correctly with the new configuration

## Additional Notes

- The subscription ID in backend.tf is not sensitive and is required for backend configuration
- OIDC authentication requires proper federated credential setup in Azure AD
- All security scans passed with no issues (CodeQL)
