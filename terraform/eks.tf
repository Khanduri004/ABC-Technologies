module "eks_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name                 = "my-cluster"
  kubernetes_version   = "1.29"
  endpoint_public_access = true
  
  addons = {
    coredns = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }


  vpc_id      = aws_vpc.this.id
  subnet_ids  = aws_subnet.public[*].id    # <- temp test with public subnet

  create_node_security_group = true        # <- let module manage SG rules

  eks_managed_node_groups = {
    default = {
      desired_size   = 2
      max_size       = 3
      min_size       = 1
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      key_name       = var.ec2_key_name
    }
  }

  enable_cluster_creator_admin_permissions = true
}