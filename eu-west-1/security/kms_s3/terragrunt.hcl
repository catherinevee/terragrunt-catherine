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
  aliases = ["alias/s3-key"]
  description = "KMS key for S3 encryption"
  
  key_usage = "ENCRYPT_DECRYPT"
  key_spec  = "SYMMETRIC_DEFAULT"
  
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
      sid    = "Allow S3 service"
      effect = "Allow"
      principals = [
        {
          type        = "Service"
          identifiers = ["s3.amazonaws.com"]
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
  
  enable_key_rotation = true
  deletion_window_in_days = 7
}