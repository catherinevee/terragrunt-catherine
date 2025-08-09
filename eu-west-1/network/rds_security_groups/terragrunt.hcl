include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "vpc" {
  config_path = "../../network/vpc"
  
  mock_outputs = {
    vpc_id = "vpc-mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "web_sg" {
  config_path = "../../network/security_groups"
  
  mock_outputs = {
    security_group_id = "sg-mock-web"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

terraform {
  source = "tfr://terraform-aws-modules/security-group/aws?version=5.1.0"
}

inputs = {
  name        = "rds-postgres"
  description = "Security group for RDS PostgreSQL database"
  vpc_id      = dependency.vpc.outputs.vpc_id

  # Allow PostgreSQL access only from web servers
  ingress_with_source_security_group_id = [
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "PostgreSQL from web servers"
      source_security_group_id = dependency.web_sg.outputs.security_group_id
    }
  ]
  
  # No outbound rules needed for RDS
  egress_rules = []
}