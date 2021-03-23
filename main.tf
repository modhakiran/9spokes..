provider "aws" {
  access_key = "AKIAYBTIVWWT7QYD334N"
  secret_key = "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"
  region     = "us-east-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "9spokes-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/dev-9spokes-eks-k8s" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/dev-9spokes-eks-k8s" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

##EKS


data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "dev-9spokes-eks-k8s"
  cluster_version = "1.19"
  subnets         = module.vpc.public_subnets
  vpc_id          = module.vpc.vpc_id

  worker_groups = [
    {
      instance_type = "t3.large"
      asg_desired_capacity = 1
      asg_max_size  = 5
    }
  ]
  
}