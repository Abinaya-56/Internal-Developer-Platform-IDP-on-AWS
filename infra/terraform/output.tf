output "aws_region" {
  value = var.aws_region
}

output "k8s_node_public_ip" {
  description = "Public IP of the k3s node"
  value       = aws_instance.k8s_node.public_ip
}

output "ssh_private_key_path" {
  description = "Path to the auto-generated private key used to SSH into the node"
  value       = local_sensitive_file.idp_private_key.filename
}
