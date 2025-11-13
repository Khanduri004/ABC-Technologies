module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name                 = "my-cluster"
  kubernetes_version   = "1.29"
  endpoint_public_access = true
  endpoint_private_access = false
  enable_cluster_creator_admin_permissions = true

  addons = {
   coredns                = {}
   eks-pod-identity-agent = {
    before_compute = true
   }
   kube-proxy             = {}
   vpc-cni                = {
    before_compute = true }
  }


  vpc_id      = aws_vpc.this.id
  #subnet_ids  = aws_subnet.public[*].id    # <- temp test with public subnet
  subnet_ids  = aws_subnet.private[*].id
  control_plane_subnet_ids = aws_subnet.private[*].id

  
  compute_config = {
   enabled = false  
  }

  create_node_security_group = true        # <- let module manage SG rules
  
  eks_managed_node_groups = {
  default = {
    desired_size   = 2
    max_size       = 3
    min_size       = 1
    instance_types = ["t3.medium"]
    ami_type       = "AL2023_x86_64_STANDARD"  
    capacity_type  = "ON_DEMAND"
    key_name       = var.ec2_key_name
  }
}
}  
