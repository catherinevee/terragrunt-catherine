include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "vpc" {
  config_path = "../../network/vpc"
  
  mock_outputs = {
    private_subnets = ["subnet-mock"]
    vpc_id = "vpc-mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "sg" {
  config_path = "../../network/security_groups"
  
  mock_outputs = {
    security_group_id = "sg-mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

terraform {
  source = "tfr://terraform-aws-modules/ec2-instance/aws?version=5.5.0"
}

locals {
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}

inputs = {
  name = "web-server"

  instance_type               = local.region_vars.locals.default_instance_type
  monitoring                  = true
  vpc_security_group_ids      = [dependency.sg.outputs.security_group_id]
  subnet_id                   = dependency.vpc.outputs.private_subnets[0]
  
  create_iam_instance_profile = true
  iam_role_description       = "IAM role for web server"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  
  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      volume_size = 20
    }
  ]
  
  enable_volume_tags = true
  volume_tags = { Backup = "true" }
}
