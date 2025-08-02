include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "vpc" {
  config_path = "../../network/vpc"
  
  mock_outputs = {
    private_subnets = ["subnet-mock-1", "subnet-mock-2"]
    vpc_id = "vpc-mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

terraform {
  source = "tfr://terraform-aws-modules/rds/aws?version=6.1.1"
}

inputs = {
  identifier = "main-db"

  engine               = "postgres"
  engine_version      = "14"
  family              = "postgres14"
  major_engine_version = "14"
  instance_class      = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 100
  
  db_name  = "appdb"
  username = "dbadmin"
  port     = 5432
  
  multi_az               = false
  db_subnet_group_name   = dependency.vpc.outputs.database_subnet_group_name
  vpc_security_group_ids = []
  
  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                  = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  
  backup_retention_period = 7
  skip_final_snapshot    = true
  deletion_protection    = true

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role               = true
  monitoring_interval                  = 60
  monitoring_role_name                 = "rds-monitoring-role"
  
  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]
  
  tags = {
    Environment = "dev"
    Project     = "main"
  }
}
