locals {
  # Load account-specific variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  
  # Load region-specific variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  
  # Extract commonly used variables
  aws_region   = local.region_vars.locals.aws_region
  environment  = get_env("TF_VAR_environment", "dev")
  account_name = local.account_vars.locals.account_name
  
  # Define common tags
  common_tags = {
    Environment = local.environment
    ManagedBy   = "Terragrunt"
    Owner       = "DevOps"
  }
}

# Generate provider configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = "1.13.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.2.0"
    }
  }
}

provider "aws" {
  region = "${local.aws_region}"
  
  default_tags {
    tags = ${jsonencode(local.common_tags)}
  }
}
EOF
}

# Configure remote state storage
remote_state {
  backend = "s3"
  config = {
    bucket         = "terragrunt-${local.account_name}-${local.aws_region}-tfstate"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
    dynamodb_table = "terraform-locks"
    
    tags = local.common_tags
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Configure inputs that are common to all modules
inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
  {
    environment = local.environment
    tags        = local.common_tags
  }
)
