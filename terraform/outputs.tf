output "region" {
  description = "The AWS region where resources are created"
  value       = var.aws_region
}
output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.this.id
}

output "ec2_public_ip" {
  description = "EC2 CI server public IP"
  value       = aws_instance.ci_server.public_ip
}

output "ec2_instance_id" {
  value = aws_instance.ci_server.id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_node_group_public_ips" {
  description = "Public IPs of the EKS node group instances"
  value       = module.eks.cluster_security_group_id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}
