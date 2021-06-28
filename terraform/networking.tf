
module "member_api_vpc" {
  source = "./modules/aws-vpc/"

  #vpc_cidr_shift = lookup(var.vpc_net_shift, terraform.workspace)
  vpc_cidr = lookup(var.vpc_network, terraform.workspace)
  vpc_type = "Private"
  tenancy  = "default"
  tags = merge(var.common_tags,
    {
      Environment = terraform.workspace
  })
  log_bucket_arn = ""
  project_name   = var.project_name

  multi_az_cidr_shift  = 4
  single_az_cidr_shift = 2
}

module "member_api_vpcendpoints" {
  source = "./modules/aws-vpcendpoints/"

  vpc     = module.member_api_vpc.vpc
  subnets = module.member_api_vpc.subnet_endpoints
  tags = merge(var.common_tags,
    {
      Environment = terraform.workspace
  })
  project_name = var.project_name
}
