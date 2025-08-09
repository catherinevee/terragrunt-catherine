include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "envcommon" {
  path   = find_in_parent_folders("_envcommon/rds.hcl")
  expose = true
}

dependency "vpc" {
  config_path = "../../network/vpc"
  
  mock_outputs = {
    private_subnets = ["subnet-mock-1", "subnet-mock-2"]
    vpc_id = "vpc-mock"
    database_subnet_group_name = "mock-db-subnet-group"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "rds_sg" {
  config_path = "../../network/rds_security_groups"
  
  mock_outputs = {
    security_group_id = "sg-mock-rds"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

terraform {
  source = "tfr://terraform-aws-modules/rds/aws?version=6.1.1"
}

inputs = merge(
  include.envcommon.locals.rds_defaults,
  {
    identifier = "main-db"

    engine               = "postgres"
    engine_version      = "14.9"
    family              = "postgres14"
    major_engine_version = "14"
    instance_class      = "db.t3.micro"

    allocated_storage     = 20
    max_allocated_storage = 100
    storage_type         = "gp3"
    
    db_name  = "appdb"
    username = get_env("TF_VAR_db_username", "dbadmin")
    port     = 5432
    
    # KMS key configuration
    master_user_secret_kms_key_id   = get_env("TF_VAR_kms_key_id", "alias/rds-key")
    kms_key_id                      = get_env("TF_VAR_kms_key_id", "alias/rds-key")
    performance_insights_kms_key_id = get_env("TF_VAR_kms_key_id", "alias/rds-key")
    
    # Enable Multi-AZ for high availability
    multi_az               = true
    db_subnet_group_name   = dependency.vpc.outputs.database_subnet_group_name
    vpc_security_group_ids = [dependency.rds_sg.outputs.security_group_id]
    
    # Final snapshot configuration
    final_snapshot_identifier = "main-db-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
    monitoring_role_name      = "rds-monitoring-role"
  }
)
