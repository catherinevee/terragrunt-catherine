include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "tfr://terraform-aws-modules/vpc/aws?version=5.1.2"
}

locals {
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}

inputs = {
  name = "main-vpc"
  cidr = "10.0.0.0/16"

  azs             = local.region_vars.locals.azs
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  
  enable_nat_gateway = true
  single_nat_gateway = false
  one_nat_gateway_per_az = true
  
  enable_vpn_gateway = false
  
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
  
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
}
