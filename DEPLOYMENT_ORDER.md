# Deployment Order

Deploy the infrastructure in the following order to satisfy dependencies:

## Prerequisites

Set the following environment variables:
```bash
export AWS_ACCOUNT_ID="your-account-id"
export TF_VAR_kms_key_id="alias/your-kms-key"
export TF_VAR_cost_center="your-cost-center"
export TF_VAR_db_username="your-db-username"
```

## Deployment Steps

### 1. KMS Keys (Deploy First)
```bash
cd eu-west-1/security/kms_terraform_state
terragrunt apply

cd ../kms_rds
terragrunt apply

cd ../kms_s3
terragrunt apply

cd ../kms_ebs
terragrunt apply
```

### 2. Network Layer
```bash
cd ../../network/vpc
terragrunt apply

cd ../security_groups
terragrunt apply

cd ../rds_security_groups
terragrunt apply
```

### 3. IAM Roles
```bash
cd ../../security/iam
terragrunt apply
```

### 4. Database Layer
```bash
cd ../../database/rds
terragrunt apply
```

### 5. Storage Layer
```bash
cd ../../storage/s3
terragrunt apply
```

### 6. Compute Layer
```bash
cd ../../compute/ec2
terragrunt apply
```

## Verification

After deployment, verify:
- All resources are encrypted with customer-managed KMS keys
- Security groups follow least privilege
- RDS is running in Multi-AZ mode
- All resources have proper tags