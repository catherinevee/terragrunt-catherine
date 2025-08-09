locals {
  rds_defaults = {
    # Security settings
    storage_encrypted                    = true
    manage_master_user_password         = true
    deletion_protection                 = true
    
    # Backup and maintenance
    backup_retention_period             = 7
    backup_window                       = "03:00-06:00"
    maintenance_window                  = "Mon:00:00-Mon:03:00"
    skip_final_snapshot                 = false
    
    # Monitoring
    performance_insights_enabled        = true
    performance_insights_retention_period = 7
    create_monitoring_role              = true
    monitoring_interval                 = 60
    enabled_cloudwatch_logs_exports     = ["postgresql", "upgrade"]
    
    # Common parameters
    parameters = [
      {
        name  = "autovacuum"
        value = 1
      },
      {
        name  = "client_encoding"
        value = "utf8"
      },
      {
        name  = "log_statement"
        value = "all"
      },
      {
        name  = "log_min_duration_statement"
        value = 1000
      }
    ]
  }
}