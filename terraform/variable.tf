variable "vpc_cidr" {
    description = "CIDR for VPC"
    type        = string
}

variable "public_subnets_cidr" {
    description = "CIDR for Public Subnet VPC"
    type        = list(string)
}

variable "private_subnets_cidr" {
    description = "CIDR for Private Subnet VPC"
    type        = list(string)
}

variable "instance_type" {
    description = "Instance type for Jenkins Server"
    type        = string
}