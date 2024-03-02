module "eks_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "eks-vpc"
  cidr = var.vpc_cidr

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