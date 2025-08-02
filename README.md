# Terragrunt Catherine - AWS Infrastructure

This repository contains a modular AWS infrastructure deployment using Terragrunt for better code organization and reusability. The infrastructure is designed following AWS best practices for security, scalability, and maintainability.

## 🎯 Key Features

- **Modular Infrastructure**: Components are organized into reusable modules
- **Infrastructure as Code**: Version-controlled using Terragrunt and Terraform
- **Security First**: Built-in security controls and encryption
- **High Availability**: Resources deployed across multiple availability zones
- **Cost Optimization**: Resource sizing based on requirements
- **Automated Management**: Infrastructure lifecycle automation
- **Compliance Ready**: Follows AWS security best practices

## 🗺️ Resource Map

```mermaid
graph TB
    subgraph Core Network
        VPC[VPC] --> SUBNETS[Private & Public Subnets]
        SUBNETS --> SG[Security Groups]
        SUBNETS --> NGW[NAT Gateways]
        SUBNETS --> IGW[Internet Gateway]
    end

    subgraph Compute Resources
        EC2[EC2 Instances]
        ASG[Auto Scaling Groups]
        EC2VOL[EBS Volumes]
        SG --> EC2
        EC2 --> EC2VOL
        ASG --> EC2
    end

    subgraph Storage Layer
        S3[S3 Buckets]
        S3LOG[S3 Logging Buckets]
        S3 --> S3LOG
    end

    subgraph Database Layer
        RDS[RDS Instances]
        RDSSG[RDS Security Groups]
        SG --> RDSSG
        RDSSG --> RDS
    end

    subgraph Security & IAM
        IAM[IAM Roles]
        KMS[KMS Keys]
        SSM[Systems Manager]
        IAM --> EC2
        KMS --> RDS
        KMS --> S3
        SSM --> EC2
    end
```

## 📊 Resource Configuration Matrix

### Network Configuration

| Component | eu-west-1 |
|-----------|-----------|
| VPC CIDR | 10.0.0.0/16 |
| Public Subnets | 10.0.1.0/24, 10.0.2.0/24 |
| Private Subnets | 10.0.101.0/24, 10.0.102.0/24 |
| NAT Gateways | One per AZ |
| VPC Flow Logs | Enabled |

### Compute Resources

| Component | Specification |
|-----------|--------------|
| EC2 Instance Types | t3.micro - t3.large |
| Auto Scaling | Min: 2, Max: 6 |
| EBS Volume Types | gp3 |
| EBS Volume Size | 50GB |

### Database Configuration

| Component | Specification |
|-----------|--------------|
| Engine | PostgreSQL |
| Instance Class | db.t3.medium |
| Storage | 100GB gp3 |
| Multi-AZ | Yes |
| Backup Retention | 7 days |

### Security Features

| Component | Configuration |
|-----------|--------------|
| Security Groups | Least privilege access |
| KMS Encryption | All resources |
| IAM Roles | Service-specific |
| SSL/TLS | Required |

## � Getting Started

### Prerequisites

- Terraform >= 1.0.0
- Terragrunt = 0.84.0
- AWS CLI configured with appropriate credentials

### Initial Setup

1. Clone the repository:
```bash
git clone https://github.com/catherinevee/terragrunt-catherine.git
cd terragrunt-catherine
```

2. Initialize and apply the infrastructure:
```bash
cd eu-west-1
terragrunt run-all init
terragrunt run-all plan
terragrunt run-all apply
```

## 🔐 Security Best Practices

- All data encrypted at rest using KMS
- Network security groups with minimal access
- IAM roles following principle of least privilege
- VPC Flow Logs enabled for network monitoring
- Regular security patches and updates
- Secure access via Systems Manager

## 🔄 Maintenance

- Regular infrastructure updates
- Automated backups and snapshots
- Performance monitoring via CloudWatch
- Cost optimization reviews
- Security compliance checks

## �📁 Directory Structure

```
terragrunt-catherine/
├── README.md                     # Project documentation
├── eu-west-1/                   # Primary region resources
│   ├── region.hcl               # Region-specific variables
│   ├── root.hcl                 # Root configuration
│   ├── _envcommon/             # Common configurations
│   ├── compute/
│   │   └── ec2/                # EC2 instances with auto-scaling
│   ├── database/
│   │   └── rds/                # RDS PostgreSQL instances
│   ├── network/
│   │   ├── vpc/                # VPC and subnet configurations
│   │   └── security_groups/    # Network security rules
│   ├── security/
│   │   └── iam/                # IAM roles and policies
│   └── storage/
│       └── s3/                 # S3 buckets with versioning
│   │   └── rds/                 # RDS instances
│   ├── network/
│   │   ├── security_groups/     # Security Groups
│   │   └── vpc/                 # VPC configuration
│   ├── security/
│   │   └── iam/                 # IAM roles and policies
│   └── storage/
│       └── s3/                  # S3 buckets
```

## 🔒 Security Controls

### Network Security
- VPC flow logs enabled
- Private subnets for sensitive resources
- Security groups with minimal required access
- NAT gateways for private subnet internet access

### Data Security
- Encryption at rest using KMS
- Encryption in transit required
- S3 bucket versioning enabled
- Regular RDS snapshots

### Access Control
- IAM roles with least privilege
- Service-linked roles where applicable
- No direct SSH access to instances
- Systems Manager for instance management

## 🔄 Resource Dependencies

1. **VPC & Network**
   - VPC must be created first
   - Security Groups depend on VPC
   - NAT Gateways require public subnets

2. **Compute Layer**
   - EC2 instances require VPC and Security Groups
   - Auto Scaling Groups depend on Launch Templates
   - EBS volumes attached to EC2 instances

3. **Database Layer**
   - RDS requires private subnets
   - Security Groups must be configured
   - KMS keys must exist for encryption

4. **Storage Layer**
   - S3 buckets require KMS keys
   - Logging buckets must exist first
   - IAM roles needed for access

## 🚀 Deployment Strategy

1. Infrastructure is deployed in the following order:
   - Network resources
   - Security configurations
   - Storage resources
   - Database layer
   - Compute resources

2. Each component can be deployed independently using:
   ```bash
   terragrunt plan
   terragrunt apply
   ```

## 🔍 Monitoring & Maintenance

- CloudWatch metrics enabled for all resources
- VPC flow logs for network monitoring
- RDS enhanced monitoring enabled
- Auto Scaling metrics collected
- Regular backup and snapshot schedule

## 🏷️ Resource Tagging

All resources are tagged with:
- Environment
- Project
- Owner
- CostCenter
- ManagedBy: "terragrunt"