module "eks_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "eks-vpc"
  cidr = var.vpc_cidr

  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = true

  azs             = ["ap-southeast-1a", "ap-southeast-1b"]
  private_subnets = var.private_subnets_cidr
  public_subnets  = var.public_subnets_cidr

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "jenkins_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "jenkins-sg"
  description = "Security group for Jenkins subnet"
  vpc_id      = module.eks_vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "Jenkins port"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
  {
    from_port   = -1
    to_port     = -1
    protocol    = -1
    cidr_blocks = "0.0.0.0/0"
  },
]
}


module "public_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "public-sg"
  description = "Security group for Public subnet"
  vpc_id      = module.eks_vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
  {
    from_port   = -1
    to_port     = -1
    protocol    = -1
    cidr_blocks = "0.0.0.0/0"
  },
]
}


module "private_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "private-sg"
  description = "Security group for Private subnet"
  vpc_id      = module.eks_vpc.vpc_id

  egress_with_cidr_blocks = [
  {
    from_port   = -1
    to_port     = -1
    protocol    = -1
    cidr_blocks = "0.0.0.0/0"
  },
]
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins-instance"
  ami           = data.aws_ami.amazon_linux.id

  instance_type          = var.instance_type
  key_name               = "jenkins-key"
  vpc_security_group_ids = [module.jenkins_sg.security_group_id]
  subnet_id              = module.eks_vpc.public_subnets[0]
  associate_public_ip_address = true
  user_data = file("jenkins-setup.sh")

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "eks-cluster"
  cluster_version = "1.29"

  cluster_endpoint_public_access = true

  vpc_id     = module.eks_vpc.vpc_id
  subnet_ids = module.eks_vpc.private_subnets

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    nodes = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t2.small"]
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}