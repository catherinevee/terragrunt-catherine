Feature: Infrastructure Compliance Rules
  As a DevOps engineer
  I want to ensure infrastructure meets compliance requirements
  So that we maintain security and operational standards

  Background:
    Given I have AWS infrastructure defined
    And I am using Terraform/Terragrunt for deployment

  Scenario: Ensure all resources are properly tagged
    Given I have AWS resources
    When I apply the infrastructure
    Then all resources must have the following tags:
      | Tag Key        | Tag Value Pattern |
      | Environment    | (dev|staging|prod) |
      | Project        | .+ |
      | Owner          | .+ |
      | CostCenter     | .+ |
      | ManagedBy      | Terraform |

  Scenario: Ensure encryption is enabled for all storage resources
    Given I have storage resources
    When I apply the infrastructure
    Then all S3 buckets must have encryption enabled
    And all RDS instances must have encryption enabled
    And all EBS volumes must have encryption enabled

  Scenario: Ensure security groups follow least privilege
    Given I have security groups defined
    When I apply the infrastructure
    Then security groups must not allow 0.0.0.0/0 access
    And security groups must have specific port ranges
    And security groups must have specific source IPs

  Scenario: Ensure VPC flow logs are enabled
    Given I have VPC resources
    When I apply the infrastructure
    Then VPC flow logs must be enabled
    And flow logs must be sent to CloudWatch Logs

  Scenario: Ensure backup policies are configured
    Given I have database resources
    When I apply the infrastructure
    Then RDS instances must have backup retention enabled
    And backup retention must be at least 7 days
    And automated backups must be enabled

  Scenario: Ensure monitoring and alerting
    Given I have compute resources
    When I apply the infrastructure
    Then CloudWatch monitoring must be enabled
    And detailed monitoring must be enabled for production

  Scenario: Ensure IAM roles follow least privilege
    Given I have IAM roles defined
    When I apply the infrastructure
    Then IAM roles must not have wildcard permissions
    And IAM roles must have specific resource ARNs
    And IAM roles must have conditions where appropriate

  Scenario: Ensure network security
    Given I have network resources
    When I apply the infrastructure
    Then private subnets must be used for sensitive resources
    And NAT gateways must be configured for private subnet internet access
    And internet gateways must only be attached to public subnets

  Scenario: Ensure compliance with data protection
    Given I have data storage resources
    When I apply the infrastructure
    Then all data must be encrypted at rest
    And all data must be encrypted in transit
    And access logs must be enabled for S3 buckets 