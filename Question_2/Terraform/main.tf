module "tech_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "99tech-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-southeast-1a", "ap-southeast-1b"]
  private_subnets = []

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "public_sb_01" {
  source = "./modules/subnet"
  name = "public-sb-01"
  cidr_block = "10.0.1.0/24"
  vpc_id = module.tech_vpc.vpc_id
  zone = "ap-southeast-1a"
}


module "public_sb_02" {
  source = "./modules/subnet"
  name = "public-sb-02"
  cidr_block = "10.0.2.0/24"
  vpc_id = module.tech_vpc.vpc_id
  zone = "ap-southeast-1b"
}

module "private_sb_01" {
  source = "./modules/subnet"
  name = "private-sb-01"
  cidr_block = "10.0.3.0/24"
  vpc_id = module.tech_vpc.vpc_id
  zone = "ap-southeast-1a"
}

module "private_sb_02" {
  source = "./modules/subnet"
  name = "private-sb-02"
  cidr_block = "10.0.4.0/24"
  vpc_id = module.tech_vpc.vpc_id
  zone = "ap-southeast-1b"
}

module "public_sg" {
  source = "terraform-aws-modules/security-group/aws"
  name        = "public-sg"
  description = "public-sg"
  vpc_id      = module.tech_vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Allow ssh"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow client access web"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}

module "private_sg" {
  source = "terraform-aws-modules/security-group/aws"
  name        = "private-sg"
  description = "private-sg"
  vpc_id      = module.tech_vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Allow ssh from public subnet"
      source_security_group_id = module.public_sg.security_group_id
    }
  ]
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}

module "internet_gateway" {
  source  = "./modules/igw"
  name = "tech_igw"
  vpc_id = module.tech_vpc.vpc_id
}

module "public_route_table" {
  source  = "./modules/route_table"
  name    = "public-rtb"
  vpc_id  = module.tech_vpc.vpc_id
  subnet_ids = [module.public_sb_01.id, module.public_sb_02.id]
  routes = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = module.internet_gateway.id
    },
    {
      cidr_block = "10.0.0.0/16"
      gateway_id = "local"
    }
  ]
}

module "nat_gateway" {
  source  = "./modules/natgw"
  name = "tech_natgw"
  subnet_id = module.public_sb_01.id
}

module "private_route_table" {
  source  = "./modules/route_table"
  name    = "private-rtb"
  vpc_id  = module.tech_vpc.vpc_id
  subnet_ids = [module.private_sb_01.id, module.private_sb_02.id]
  routes = [
    {
      cidr_block = "0.0.0.0/0"
      gateway_id = module.nat_gateway.id
    },
    {
      cidr_block = "10.0.0.0/16"
      gateway_id = "local"
    }
  ]
}

module "frontend_01" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  name = "frontend_01"
  vpc_security_group_ids = [module.public_sg.security_group_id]
  instance_type          = "t2.micro"
  key_name               = "aws"
  monitoring             = false
  subnet_id              = module.public_sb_01.id
  ami           = "ami-0672fd5b9210aa093"
  associate_public_ip_address = true
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "backend_01" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  name = "backend_01"
  vpc_security_group_ids = [module.private_sg.security_group_id]
  instance_type          = "t2.micro"
  key_name               = "aws"
  monitoring             = false
  subnet_id              = module.private_sb_01.id
  ami           = "ami-0672fd5b9210aa093"
  associate_public_ip_address = false
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}