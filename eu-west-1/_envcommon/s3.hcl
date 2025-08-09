locals {
  s3_defaults = {
    # Security settings
    acl = "private"
    
    versioning = {
      enabled = true
    }
    
    # Encryption configuration
    server_side_encryption_configuration = {
      rule = {
        apply_server_side_encryption_by_default = {
          sse_algorithm     = "aws:kms"
          kms_master_key_id = get_env("TF_VAR_kms_key_id", "alias/s3-key")
        }
        bucket_key_enabled = true
      }
    }
    
    # Public access blocking
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
    
    # Common lifecycle rules
    lifecycle_rule = [
      {
        id      = "log"
        enabled = true
        prefix  = "log/"

        transition = [
          {
            days          = 30
            storage_class = "ONEZONE_IA"
          },
          {
            days          = 60
            storage_class = "GLACIER"
          }
        ]

        expiration = {
          days = 90
        }
      }
    ]
  }
}