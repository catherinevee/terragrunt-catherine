include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "envcommon" {
  path   = find_in_parent_folders("_envcommon/security_groups.hcl")
  expose = true
}

dependency "vpc" {
  config_path = "../../network/vpc"
  
  mock_outputs = {
    vpc_id = "vpc-mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

terraform {
  source = "tfr://terraform-aws-modules/security-group/aws?version=5.1.0"
}

inputs = {
  name        = "web-server"
  description = "Security group for web servers"
  vpc_id      = dependency.vpc.outputs.vpc_id

  # Restrict ingress to VPC CIDR only
  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP from ALB only"
      cidr_blocks = include.envcommon.locals.security_group_defaults.vpc_cidr
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS from ALB only"
      cidr_blocks = include.envcommon.locals.security_group_defaults.vpc_cidr
    }
  ]
  
  # Use shared egress rules
  egress_with_cidr_blocks = include.envcommon.locals.security_group_defaults.web_server_egress
}
