# AWS OIDC Setup for GitHub Actions

This guide provides step-by-step instructions for setting up OpenID Connect (OIDC) authentication between GitHub Actions and AWS, eliminating the need for long-lived AWS access keys.

## 🔐 Overview

OIDC allows GitHub Actions to authenticate with AWS using short-lived tokens instead of long-lived access keys, significantly improving security posture.

## 📋 Prerequisites

- AWS CLI configured with appropriate permissions
- GitHub repository access
- AWS account with IAM permissions

## 🚀 Setup Steps

### Step 1: Create OIDC Identity Provider

Create the OIDC identity provider in AWS IAM:

```bash
# Create OIDC provider for GitHub Actions
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 \
  --tags Key=Purpose,Value=GitHubActions
```

### Step 2: Create IAM Role

Create the IAM role that GitHub Actions will assume:

```bash
# Create trust policy document
cat > trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:catherinevee/terragrunt-catherine:*"
        }
      }
    }
  ]
}
EOF

# Create the IAM role
aws iam create-role \
  --role-name GitHubActionsTerraform \
  --assume-role-policy-document file://trust-policy.json \
  --description "Role for GitHub Actions Terraform operations" \
  --tags Key=Purpose,Value=GitHubActions
```

### Step 3: Create IAM Policy

Create the IAM policy with necessary permissions for Terraform operations:

```bash
# Create policy document
cat > terraform-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "rds:*",
        "s3:*",
        "iam:*",
        "kms:*",
        "cloudwatch:*",
        "logs:*",
        "autoscaling:*",
        "elasticloadbalancing:*",
        "route53:*",
        "acm:*",
        "waf:*",
        "wafv2:*",
        "shield:*",
        "guardduty:*",
        "securityhub:*",
        "config:*",
        "backup:*",
        "ce:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "sts:GetCallerIdentity",
        "sts:AssumeRole"
      ],
      "Resource": "*"
    }
  ]
}
EOF

# Create the policy
aws iam create-policy \
  --policy-name GitHubActionsTerraformPolicy \
  --policy-document file://terraform-policy.json \
  --description "Policy for GitHub Actions Terraform operations"
```

### Step 4: Attach Policy to Role

Attach the policy to the IAM role:

```bash
# Get the policy ARN
POLICY_ARN=$(aws iam list-policies --query 'Policies[?PolicyName==`GitHubActionsTerraformPolicy`].Arn' --output text)

# Attach policy to role
aws iam attach-role-policy \
  --role-name GitHubActionsTerraform \
  --policy-arn $POLICY_ARN
```

### Step 5: Get Role ARN

Get the role ARN to use in GitHub secrets:

```bash
# Get the role ARN
ROLE_ARN=$(aws iam get-role --role-name GitHubActionsTerraform --query 'Role.Arn' --output text)
echo "Role ARN: $ROLE_ARN"
```

### Step 6: Configure GitHub Secrets

1. Go to your GitHub repository
2. Navigate to Settings > Secrets and variables > Actions
3. Click "New repository secret"
4. Add the following secret:
   - **Name**: `AWS_ROLE_ARN`
   - **Value**: The role ARN from Step 5

### Step 7: Test the Setup

Create a test workflow to verify the OIDC setup:

```yaml
# .github/workflows/test-oidc.yml
name: Test OIDC Setup

on:
  workflow_dispatch:

permissions:
  id-token: write
  contents: read

jobs:
  test-oidc:
    runs-on: ubuntu-latest
    steps:
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          role-session-name: GitHubActions-Test
          aws-region: eu-west-1
      
      - name: Test AWS access
        run: |
          aws sts get-caller-identity
          aws ec2 describe-regions --query 'Regions[0].RegionName' --output text
```

## 🔧 Advanced Configuration

### Environment-Specific Roles

For different environments (dev, staging, prod), create separate roles:

```bash
# Create environment-specific roles
for env in dev staging prod; do
  # Create role for each environment
  aws iam create-role \
    --role-name GitHubActionsTerraform${env^} \
    --assume-role-policy-document file://trust-policy.json \
    --description "Role for GitHub Actions Terraform operations - $env"
  
  # Attach policy
  aws iam attach-role-policy \
    --role-name GitHubActionsTerraform${env^} \
    --policy-arn $POLICY_ARN
done
```

### Conditional Access

Modify the trust policy to restrict access based on repository and branch:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:catherinevee/terragrunt-catherine:*"
        },
        "StringEquals": {
          "token.actions.githubusercontent.com:ref": "refs/heads/main"
        }
      }
    }
  ]
}
```

### Least Privilege Policy

Create a more restrictive policy for production:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "ec2:Get*",
        "rds:Describe*",
        "s3:Get*",
        "s3:List*",
        "iam:Get*",
        "kms:Describe*",
        "cloudwatch:Get*",
        "logs:Get*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Create*",
        "ec2:Modify*",
        "ec2:Delete*",
        "rds:Create*",
        "rds:Modify*",
        "rds:Delete*",
        "s3:Put*",
        "s3:Delete*",
        "iam:Create*",
        "iam:Update*",
        "iam:Delete*"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:RequestTag/Environment": "prod"
        }
      }
    }
  ]
}
```

## 🔍 Troubleshooting

### Common Issues

1. **Invalid Token Error**
   ```bash
   # Check OIDC provider configuration
   aws iam get-open-id-connect-provider \
     --open-id-connect-provider-arn arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com
   ```

2. **Permission Denied**
   ```bash
   # Verify role permissions
   aws iam list-attached-role-policies --role-name GitHubActionsTerraform
   ```

3. **Trust Policy Issues**
   ```bash
   # Check trust policy
   aws iam get-role --role-name GitHubActionsTerraform --query 'Role.AssumeRolePolicyDocument'
   ```

### Debug Commands

```bash
# Test role assumption
aws sts assume-role-with-web-identity \
  --role-arn arn:aws:iam::YOUR_ACCOUNT_ID:role/GitHubActionsTerraform \
  --role-session-name test-session \
  --web-identity-token YOUR_TOKEN

# Check caller identity
aws sts get-caller-identity

# List IAM roles
aws iam list-roles --query 'Roles[?contains(RoleName, `GitHubActions`)].RoleName'
```

## 📊 Security Benefits

### Before OIDC (Long-lived Keys)
- ❌ Long-lived access keys stored in GitHub secrets
- ❌ Keys never expire automatically
- ❌ Keys can be used from anywhere
- ❌ Difficult to rotate keys
- ❌ No audit trail for key usage

### After OIDC (Short-lived Tokens)
- ✅ No long-lived secrets stored
- ✅ Tokens expire automatically (1 hour)
- ✅ Tokens can only be used from GitHub Actions
- ✅ Automatic token rotation
- ✅ Complete audit trail
- ✅ Conditional access based on repository/branch

## 🔄 Maintenance

### Regular Tasks

1. **Review Permissions** (Monthly)
   ```bash
   # Review attached policies
   aws iam list-attached-role-policies --role-name GitHubActionsTerraform
   ```

2. **Audit Usage** (Weekly)
   ```bash
   # Check CloudTrail for role usage
   aws logs filter-log-events \
     --log-group-name CloudTrail/DefaultLogGroup \
     --filter-pattern '{ $.userIdentity.arn = "arn:aws:sts::*:assumed-role/GitHubActionsTerraform/*" }'
   ```

3. **Update Policies** (As needed)
   ```bash
   # Update policy when new services are added
   aws iam update-role-description \
     --role-name GitHubActionsTerraform \
     --description "Updated description"
   ```

### Security Monitoring

Set up CloudWatch alarms for role usage:

```bash
# Create CloudWatch alarm for role usage
aws cloudwatch put-metric-alarm \
  --alarm-name GitHubActionsRoleUsage \
  --alarm-description "Monitor GitHub Actions role usage" \
  --metric-name RoleUsage \
  --namespace AWS/IAM \
  --statistic Sum \
  --period 300 \
  --threshold 10 \
  --comparison-operator GreaterThanThreshold
```

## 📚 References

- [GitHub Actions OIDC Documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [AWS OIDC Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)
- [Terraform AWS Provider OIDC](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/iam-roles-for-service-accounts-oidc)

---

**Note**: This setup provides enterprise-grade security for GitHub Actions AWS authentication. The OIDC implementation eliminates the need for long-lived secrets and provides comprehensive audit trails. 