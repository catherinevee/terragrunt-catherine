include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "tfr://terraform-aws-modules/iam/aws//modules/iam-assumable-role?version=5.30.0"
}

inputs = {
  trusted_role_services = [
    "ec2.amazonaws.com"
  ]
  
  create_role             = true
  create_instance_profile = true
  
  role_name         = "ec2-default-role"
  role_requires_mfa = false

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
  
  tags = {
    Role = "EC2-Default"
  }
}
