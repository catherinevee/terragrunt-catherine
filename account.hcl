locals {
  account_name = "dev"
  account_id   = get_env("AWS_ACCOUNT_ID")
  
  # Validate account ID is set
  validated_account_id = local.account_id != "" ? local.account_id : run_cmd("--terragrunt-quiet", "aws", "sts", "get-caller-identity", "--query", "Account", "--output", "text")
  
  # Account-specific configurations
  aws_profile = get_env("AWS_PROFILE", "default")
}
