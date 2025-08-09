include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "tfr://terraform-aws-modules/kms/aws?version=2.2.1"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

inputs = {
  # Main application key for general encryption
  aliases = ["alias/app-key"]
  description = "KMS key for application encryption"
  
  key_usage = "ENCRYPT_DECRYPT"
  key_spec  = "SYMMETRIC_DEFAULT"
  
  # Key policy allowing root account access and specific services
  key_statements = [
    {
      sid    = "Enable IAM User Permissions"
      effect = "Allow"
      principals = [
        {
          type        = "AWS"
          identifiers = ["arn:aws:iam::${local.account_vars.locals.validated_account_id}:root"]
        }
      ]
      actions   = ["kms:*"]
      resources = ["*"]
    },
    {
      sid    = "Allow use of the key for AWS services"
      effect = "Allow"
      principals = [
        {
          type        = "Service"
          identifiers = ["rds.amazonaws.com", "s3.amazonaws.com", "ec2.amazonaws.com"]
        }
      ]
      actions = [
        "kms:Decrypt",
        "kms:GenerateDataKey*",
        "kms:ReEncrypt*",
        "kms:DescribeKey"
      ]
      resources = ["*"]
    }
  ]
  
  # Enable key rotation
  enable_key_rotation = true
  
  # Deletion window
  deletion_window_in_days = 7
}