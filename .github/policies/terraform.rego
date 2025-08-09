package terraform

# Ensure all resources have required tags
deny[msg] {
    resource := input.resource_changes[_]
    resource.change.after.tags
    required_tags := {"Environment", "Project", "Owner", "CostCenter", "ManagedBy"}
    missing_tags := required_tags - object.keys(resource.change.after.tags)
    count(missing_tags) > 0
    msg := sprintf("Resource %s is missing required tags: %v", [resource.address, missing_tags])
}

# Ensure S3 buckets have encryption enabled
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    not resource.change.after.server_side_encryption_configuration
    msg := sprintf("S3 bucket %s must have encryption enabled", [resource.address])
}

# Ensure RDS instances have encryption enabled
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_db_instance"
    not resource.change.after.storage_encrypted
    msg := sprintf("RDS instance %s must have encryption enabled", [resource.address])
}

# Ensure EBS volumes have encryption enabled
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_ebs_volume"
    not resource.change.after.encrypted
    msg := sprintf("EBS volume %s must have encryption enabled", [resource.address])
}

# Ensure security groups don't allow 0.0.0.0/0 access
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_security_group_rule"
    resource.change.after.cidr_blocks[_] == "0.0.0.0/0"
    resource.change.after.type == "ingress"
    msg := sprintf("Security group rule %s allows 0.0.0.0/0 access", [resource.address])
}

# Ensure VPC flow logs are enabled
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_vpc"
    not resource.change.after.enable_flow_logs
    msg := sprintf("VPC %s must have flow logs enabled", [resource.address])
}

# Ensure RDS instances have backup retention
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_db_instance"
    resource.change.after.backup_retention_period < 7
    msg := sprintf("RDS instance %s must have backup retention of at least 7 days", [resource.address])
}

# Ensure IAM roles don't have wildcard permissions
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_iam_role_policy"
    policy := resource.change.after.policy
    contains(policy, '"Action": "*"')
    msg := sprintf("IAM role policy %s contains wildcard permissions", [resource.address])
}

# Ensure private subnets are used for RDS
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_db_subnet_group"
    subnet := resource.change.after.subnet_ids[_]
    not is_private_subnet(subnet)
    msg := sprintf("RDS subnet group %s contains public subnets", [resource.address])
}

# Ensure S3 buckets have versioning enabled
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_versioning"
    not resource.change.after.versioning_configuration[0].status == "Enabled"
    msg := sprintf("S3 bucket %s must have versioning enabled", [resource.address])
}

# Ensure CloudWatch monitoring is enabled for EC2 instances
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_instance"
    not resource.change.after.monitoring
    msg := sprintf("EC2 instance %s must have monitoring enabled", [resource.address])
}

# Helper function to check if subnet is private
is_private_subnet(subnet_id) {
    subnet := data.aws_subnet[subnet_id]
    subnet.map_public_ip_on_launch == false
}

# Ensure proper naming conventions
deny[msg] {
    resource := input.resource_changes[_]
    name := resource.change.after.tags.Name
    not startswith(name, "catherine-")
    msg := sprintf("Resource %s must follow naming convention: catherine-*", [resource.address])
}

# Ensure cost allocation tags are present
deny[msg] {
    resource := input.resource_changes[_]
    not resource.change.after.tags.CostCenter
    msg := sprintf("Resource %s must have CostCenter tag", [resource.address])
}

# Ensure environment tag is valid
deny[msg] {
    resource := input.resource_changes[_]
    env := resource.change.after.tags.Environment
    not env == "dev" || env == "staging" || env == "prod"
    msg := sprintf("Resource %s must have valid Environment tag (dev|staging|prod)", [resource.address])
} 