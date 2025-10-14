module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.17.0"

  cluster_name    = "my-cluster"
  cluster_version = "1.30"

  cluster_endpoint_public_access = true

  vpc_id     = aws_vpc.this.id
  subnet_ids = aws_subnet.private[*].id

  # EKS Managed Node Groups
  eks_managed_node_groups= {
    default = {
      desired_capacity = 2
      max_capacity     = 5
      min_capacity     = 1

      instance_type = "t3.medium"
      key_name      = var.ec2_key_name
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}


