# Create VPC and subnets
module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
}
module "networks" {
  source               = "./modules/networks"
  vpc_id               = module.vpc.vpc_id
  aws_region           = var.aws_region
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
}
# Create IAM roles and policies
module "iam" {
  source = "./modules/iam"
}
# Create Security Groups
module "security_groups" {
  source                    = "./modules/sg"
  vpc_id                    = module.vpc.vpc_id
  allowed_ssh_bastion_cidrs = var.allowed_ssh_bastion_cidrs
}
module "ec2" {
  source                   = "./modules/ec2"
  public_ssh_key           = var.public_ssh_key
  private_subnet_ids       = module.networks.private_subnet_ids
  public_subnet_ids        = module.networks.public_subnet_ids
  bastion_host_sg_id       = module.security_groups.bastion_host_sg_id
  private_hosts_sg_id      = module.security_groups.private_hosts_sg_id
  bastion_ssm_profile_name = module.iam.bastion_ssm_profile_name
  private_ssm_profile_name = module.iam.bastion_ssm_profile_name
  private_route_table_id   = module.networks.private_route_table_id
}
