# module for network-vpc
module "network_vpc" {
  source              = "../modules/network"
  project_name        = var.project_name
  vpc_cidr_block      = var.vpc_cidr_block
  public_subnets_cidr = var.public_subnets_cidr
}

# module for ec2 instances
module "ec2" {
  source              = "../modules/ec2"
  project_name        = var.project_name
  vpc_id              = module.network_vpc.project_vpc_id
  subnet_id           = module.network_vpc.project_subnet_id
  keypair_name        = var.keypair_name
  public_subnets_cidr = var.public_subnets_cidr
  instance_type       = var.instance_type
}

# module for alb
module "alb" {
  source              = "../modules/application_lb"
  public_subnets_cidr = var.public_subnets_cidr
  vpc_id              = module.network_vpc.project_vpc_id
  alb_sg              = module.ec2.security_groups
  alb_subnets         = module.network_vpc.project_subnet_id
  project_name        = var.project_name
  ec2_ids             = module.ec2.ec2_id
  domain_name         = var.domain_name
  subdomain_name_1    = var.subdomain_name_1
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "ec2_public_ip" {
  value = module.ec2.ec2_public_ip
}

output "ec2_private_ip" {
  value = module.ec2.ec2_private_ip
}



