locals {
  security_group_defaults = {
    # Common egress rules for web servers
    web_server_egress = [
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        description = "HTTP outbound for updates"
        cidr_blocks = "0.0.0.0/0"
      },
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        description = "HTTPS outbound for updates"
        cidr_blocks = "0.0.0.0/0"
      },
      {
        from_port   = 53
        to_port     = 53
        protocol    = "udp"
        description = "DNS resolution"
        cidr_blocks = "0.0.0.0/0"
      }
    ]
    
    # Common VPC CIDR for ingress rules
    vpc_cidr = "10.0.0.0/16"
  }
}