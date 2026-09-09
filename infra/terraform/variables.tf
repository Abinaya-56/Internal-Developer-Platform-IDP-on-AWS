variable "aws_region" {
  description = "AWS region for IDP infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into the k8s node. Override with your own IP/32 in a .tfvars file."
  type        = string
  default     = "0.0.0.0/0"
}

