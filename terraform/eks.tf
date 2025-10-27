locals {
  # Remote network CIDR for hybrid nodes (self-managed nodes)
  # Use your VPC CIDR if hybrid nodes are inside the same VPC
  remote_network_cidr = "172.30.0.0/16"

  # Hybrid node subnet CIDR
  remote_node_cidr = "172.30.0.0/16"

  # Pod network range for hybrid nodes
  remote_pod_cidr = "192.168.0.0/16" # Can be any unused CIDR
}
# IAM role for managed node groups
resource "aws_iam_role" "eks_node_group_role" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

# Policies for managed node groups
resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group_role.name
}

# IAM role for hybrid/self-managed nodes
resource "aws_iam_role" "eks_hybrid_node_role" {
  name = "eks-hybrid-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

# Policies for hybrid nodes
resource "aws_iam_role_policy_attachment" "hybrid_worker_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_hybrid_node_role.name
}

resource "aws_iam_role_policy_attachment" "hybrid_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_hybrid_node_role.name
}

resource "aws_iam_role_policy_attachment" "hybrid_ecr_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_hybrid_node_role.name
}

# Instance profile for hybrid nodes
resource "aws_iam_instance_profile" "eks_hybrid_node_profile" {
  name = "eks-hybrid-node-profile"
  role = aws_iam_role.eks_hybrid_node_role.name
}


# EKS Cluster Module

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> v21.0"

  #cluster_name
  name = "my-cluster"
  #cluster_version
  kubernetes_version = "1.30"
  #cluster_endpoint_public_access
  endpoint_public_access = true

  vpc_id     = aws_vpc.this.id
  subnet_ids = aws_subnet.private[*].id


  # Managed Node Groups
  eks_managed_node_groups = {
    default = {
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      key_name       = var.ec2_key_name
    }
  }

  # Addons (AWS-managed)

  addons = {
    coredns                = {}
    kube-proxy             = {}
    eks-pod-identity-agent = {}
  }


  # Grant full admin to cluster creator

  enable_cluster_creator_admin_permissions = true


  # Hybrid Node Access & Security

  create_node_security_group = false
  security_group_additional_rules = {
    hybrid-all = {
      cidr_blocks = [local.remote_network_cidr]
      description = "Allow all traffic from remote node/pod network"
      from_port   = 0
      to_port     = 0
      protocol    = "all"
      type        = "ingress"
    }
  }

  access_entries = {
    hybrid-node-role = {
      principal_arn = aws_iam_role.eks_hybrid_node_role.arn
      type          = "HYBRID_LINUX"
    }
  }


  # Remote network config for hybrid nodes

  remote_network_config = {
    remote_node_networks = {
      cidrs = [local.remote_node_cidr]
    }
    remote_pod_networks = {
      cidrs = [local.remote_pod_cidr]
    }
  }

  # Cluster tags

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

##########################################################
# Launch Template for Hybrid Nodes
##########################################################
    data "aws_ami" "eks_worker" {
  most_recent = true
  owners      = ["602401143452"] # Official Amazon EKS AMI account

  filter {
    name   = "name"
    values = ["amazon-eks-node-${module.eks.cluster_version}-*"]
  }
}


resource "aws_launch_template" "eks_hybrid" {
  name_prefix   = "eks-hybrid-"
  image_id      = data.aws_ami.eks_worker.id
  instance_type = "t3.medium"
  key_name      = var.ec2_key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.eks_hybrid_node_profile.name
  }

  user_data = base64encode(<<-EOT
              #!/bin/bash
              /etc/eks/bootstrap.sh ${module.eks.cluster_name}
              EOT
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "eks-hybrid-node"
    }
  }
}


# Auto Scaling Group for Hybrid Nodes

resource "aws_autoscaling_group" "eks_hybrid_asg" {
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = aws_subnet.private[*].id

  launch_template {
    id      = aws_launch_template.eks_hybrid.id
    version = "$Latest"
  }

  tag {
    key                 = "kubernetes.io/cluster/${module.eks.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "eks_hybrid_nodes_sg" {
  name        = "eks-hybrid-nodes-sg"
  description = "Security group for EKS hybrid nodes"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.remote_network_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-hybrid-nodes-sg"
  }
}


