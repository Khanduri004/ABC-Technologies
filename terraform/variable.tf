variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "project_name" {
  type    = string
  default = "ABC_TECHNOLOGIES"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "ec2_instance_type" {
  type    = string
  default = "t2.large"
}

variable "ec2_key_name" {
  type        = string
  description = "Name of existing EC2 keypair (optional). Leave blank to not create key."
  default     = "my-keypair"
}

variable "eks_node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "eks_desired_capacity" {
  type    = number
  default = 2
}

variable "eks_min_size" {
  type    = number
  default = 1
}

variable "eks_max_size" {
  type    = number
  default = 3
}

variable "remote_pod_cidr" {
  description = "CIDR range of pods running on hybrid nodes (if used)."
  type        = string
  default     = "172.16.0.0/16"
}


