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

output "eks_hybrid_asg_id" {
  description = "Auto Scaling Group ID for hybrid EKS nodes"
  value       = aws_autoscaling_group.eks_hybrid_asg.id
}

output "eks_hybrid_launch_template_id" {
  description = "Launch Template ID for hybrid EKS nodes"
  value       = aws_launch_template.eks_hybrid.id
}

output "eks_hybrid_sg_id" {
  description = "Security Group ID for hybrid EKS nodes"
  value       = aws_security_group.eks_hybrid_nodes_sg.id
}
