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

terraform {
  source = "tfr://terraform-aws-modules/security-group/aws?version=5.1.0"
}

inputs = {
  name        = "web-server"
  description = "Security group for web servers"
  vpc_id      = dependency.vpc.outputs.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  
  egress_rules        = ["all-all"]
}
