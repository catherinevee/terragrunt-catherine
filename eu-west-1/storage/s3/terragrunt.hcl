include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "envcommon" {
  path   = find_in_parent_folders("_envcommon/s3.hcl")
  expose = true
}

terraform {
  source = "tfr://terraform-aws-modules/s3-bucket/aws?version=3.15.1"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}

inputs = merge(
  include.envcommon.locals.s3_defaults,
  {
    bucket = "my-app-data-bucket-${local.account_vars.locals.account_name}-${local.region_vars.locals.aws_region}"
  }
)
