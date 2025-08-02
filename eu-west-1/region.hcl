locals {
  aws_region = "eu-west-1"
  
  # Define region-specific variables
  azs = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  
  # Default instance types for this region
  default_instance_type = "t3.micro"
}
