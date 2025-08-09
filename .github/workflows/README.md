# GitHub Actions Workflows for Terragrunt Catherine

This directory contains comprehensive GitHub Actions workflows for the Terragrunt Catherine infrastructure project, implementing DevSecOps best practices with security-first approach.

## 🚀 Workflow Overview

### Core Workflows

| Workflow | Purpose | Triggers | Security Level |
|----------|---------|----------|----------------|
| `terraform-plan.yml` | Infrastructure planning and validation | PR, Manual | High |
| `terraform-apply.yml` | Infrastructure deployment | Push to main, Manual | Critical |
| `security-scan.yml` | Security scanning and compliance | PR, Push, Scheduled | High |
| `cost-optimization.yml` | Cost analysis and optimization | PR, Scheduled | Medium |
| `backup-and-maintenance.yml` | Automated backup and maintenance | Scheduled, Manual | High |

## 🔒 Security Implementation

### 1. Script Injection Prevention
- ✅ All user inputs are sanitized and assigned to environment variables
- ✅ No direct use of `${{ github.event.* }}` in run commands
- ✅ Input validation for workflow_dispatch parameters
- ✅ Proper escaping of dynamic content

### 2. Token and Permissions Security
- ✅ Minimal required permissions defined per workflow
- ✅ OIDC implementation for AWS authentication
- ✅ No long-lived secrets for cloud provider access
- ✅ Job-specific permissions where appropriate
- ✅ GITHUB_TOKEN has read-only permissions by default

### 3. Third-Party Action Security
- ✅ All actions pinned to specific versions or SHA
- ✅ Actions from verified publishers only
- ✅ No use of 'main' or 'master' branches
- ✅ Regular security updates for actions

### 4. Secrets Management
- ✅ No hardcoded secrets in workflows
- ✅ Environment-specific secrets properly scoped
- ✅ Secrets never printed in logs
- ✅ GitHub Environments with protection rules
- ✅ OIDC for AWS authentication

### 5. Dangerous Trigger Events
- ✅ No use of `pull_request_target` with PR code checkout
- ✅ Proper branch protection for main branch
- ✅ Manual workflow inputs validated
- ✅ Safe event handling

## 📊 Performance Optimization

### 6. Caching Strategy
- ✅ Latest actions/cache@v4 implementation
- ✅ Appropriate cache keys using hashFiles()
- ✅ Restore-keys fallback strategy
- ✅ Cross-OS cache sharing where applicable

### 7. Job Parallelization
- ✅ Independent jobs run in parallel
- ✅ Matrix strategy for multi-platform builds
- ✅ Concurrency controls to prevent duplicate runs
- ✅ Appropriate timeout-minutes at job and step levels

### 8. Artifact Management
- ✅ Optimized artifact retention periods
- ✅ Compression for large artifacts
- ✅ Unnecessary artifact uploads avoided

## 🛡️ Security Scanning Features

### Terraform Security
- **Checkov**: Infrastructure as Code security scanning
- **TFLint**: Terraform linting and best practices
- **Trivy**: Infrastructure configuration scanning
- **Terraform Compliance**: Custom compliance rules

### Dependency Security
- **Trivy**: Vulnerability scanning for dependencies
- **OWASP Dependency Check**: Comprehensive dependency analysis
- **SARIF Integration**: Standardized security reporting

### Compliance Validation
- **Open Policy Agent (OPA)**: Policy enforcement
- **Terraform Compliance**: BDD-style compliance testing
- **Custom Policies**: Organization-specific rules

## 💰 Cost Optimization Features

### Cost Analysis
- **Infracost**: Infrastructure cost estimation
- **AWS Cost Explorer**: Historical cost analysis
- **Resource Optimization**: Unused resource detection
- **Cost Reporting**: Automated cost reports

### Optimization Recommendations
- Spot instance recommendations
- Auto-scaling optimization
- Storage class optimization
- Reserved instance suggestions

## 🔧 Maintenance and Backup

### Automated Backup
- **RDS Snapshots**: Automated database backups
- **EBS Snapshots**: Volume backups
- **S3 Backups**: Object storage backups
- **Backup Verification**: Automated validation

### Health Monitoring
- **RDS Health Checks**: Database status monitoring
- **EC2 Health Checks**: Instance status monitoring
- **S3 Health Checks**: Bucket accessibility
- **Security Group Validation**: Network security checks

### Automated Cleanup
- **Snapshot Cleanup**: Old backup removal
- **S3 Lifecycle**: Automatic object lifecycle management
- **Resource Cleanup**: Unused resource removal

## 📋 Workflow Configuration

### Environment Variables
```yaml
env:
  TF_VERSION: "1.13.0"
  TERRAGRUNT_VERSION: "0.84.0"
  AWS_REGION: "eu-west-1"
```

### Required Secrets
- `AWS_ROLE_ARN`: AWS IAM role ARN for OIDC authentication
- `GITHUB_TOKEN`: GitHub token for repository access

### Environment Protection
- **dev**: Basic protection
- **staging**: Required reviewers
- **prod**: Required reviewers + deployment protection

## 🔄 Workflow Triggers

### Automated Triggers
- **Pull Requests**: Plan and security scans
- **Push to main**: Apply and deployment
- **Scheduled**: Daily security scans, weekly cost analysis

### Manual Triggers
- **workflow_dispatch**: Manual execution with parameters
- **Environment-specific**: Targeted deployments

## 📈 Monitoring and Observability

### Structured Logging
- ✅ `::notice::` for informational messages
- ✅ `::warning::` for warnings
- ✅ `::error::` for errors
- ✅ Structured output for parsing

### Deployment Notifications
- ✅ GitHub deployment API integration
- ✅ PR comments with results
- ✅ Slack/Teams notifications (configurable)
- ✅ Email notifications for critical events

### Metrics Collection
- ✅ DORA metrics tracking
- ✅ Deployment frequency
- ✅ Lead time for changes
- ✅ Mean time to recovery
- ✅ Change failure rate

## 🚨 Error Handling

### Graceful Degradation
- ✅ `continue-on-error` for non-critical steps
- ✅ Retry logic for flaky operations
- ✅ Proper failure notifications
- ✅ Rollback procedures

### Failure Recovery
- ✅ Automatic retry for transient failures
- ✅ Manual intervention for critical failures
- ✅ State recovery procedures
- ✅ Backup restoration processes

## 📚 Compliance and Governance

### Branch Protection
- ✅ Required status checks
- ✅ Environment protection rules
- ✅ Approval requirements
- ✅ Deployment restrictions

### Audit Trail
- ✅ Complete workflow execution logs
- ✅ Resource change tracking
- ✅ Security scan results
- ✅ Cost analysis reports

### Documentation
- ✅ Inline code comments
- ✅ README documentation
- ✅ Change history tracking
- ✅ Compliance documentation

## 🔧 Setup Instructions

### 1. Repository Setup
```bash
# Clone the repository
git clone https://github.com/catherinevee/terragrunt-catherine.git
cd terragrunt-catherine

# Create .github directory structure
mkdir -p .github/workflows
mkdir -p .github/compliance
mkdir -p .github/policies
```

### 2. AWS OIDC Setup
```bash
# Create OIDC provider in AWS
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1

# Create IAM role for GitHub Actions
aws iam create-role \
  --role-name GitHubActionsTerraform \
  --assume-role-policy-document file://trust-policy.json
```

### 3. GitHub Secrets Configuration
```bash
# Add required secrets to GitHub repository
AWS_ROLE_ARN=arn:aws:iam::ACCOUNT:role/GitHubActionsTerraform
```

### 4. Environment Protection Setup
1. Go to repository Settings > Environments
2. Create environments: dev, staging, prod
3. Configure protection rules for each environment
4. Set required reviewers for staging and prod

## 🎯 Best Practices Implementation

### Security First
- All workflows follow security-first design principles
- Comprehensive input validation and sanitization
- Least privilege access implementation
- Regular security scanning and compliance checks

### Performance Optimized
- Efficient caching strategies
- Parallel job execution
- Optimized artifact management
- Resource cleanup and optimization

### Maintainable Code
- Clear workflow structure
- Comprehensive documentation
- Reusable components
- Version-controlled configurations

### Compliance Ready
- Built-in compliance validation
- Audit trail maintenance
- Governance controls
- Regulatory compliance support

## 📞 Support and Maintenance

### Regular Maintenance
- Weekly security updates
- Monthly cost optimization reviews
- Quarterly compliance audits
- Annual workflow optimization

### Monitoring
- Workflow execution monitoring
- Security scan result tracking
- Cost trend analysis
- Performance metrics collection

### Documentation Updates
- Workflow changes documented
- Security updates tracked
- Best practices updated
- Compliance requirements maintained

---

**Note**: This implementation follows the comprehensive security and best practices guidelines provided, ensuring a production-ready, secure, and maintainable CI/CD pipeline for infrastructure management. 