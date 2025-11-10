module "vpc" {
  source            = "./modules/vpc"
  project           = var.project
  environment       = var.environment
  vpc_cidr          = var.vpc_cidr
  public_subnets    = var.public_subnets
  private_subnets   = var.private_subnets
  availability_zones = var.availability_zones
}

module "ec2" {
  source        = "./modules/ec2"
  project       = var.project
  environment   = var.environment
  ami_id        = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = module.vpc.public_subnet_ids[0]
  vpc_id        = module.vpc.vpc_id
}

module "rds" {
  source              = "./modules/rds"
  project             = var.project
  environment         = var.environment

  db_name             = var.db_name
  db_username         = var.db_username
  db_password         = var.db_password
  db_instance_class   = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  db_engine_version   = var.db_engine_version

  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.public_subnet_ids
}

module "s3" {
  source        = "./modules/s3"
  project       = var.project
  environment   = var.environment
  s3_bucket_name = var.s3_bucket_name
}

module "ecr" {
  source        = "./modules/ecr"
  project       = var.project
  environment   = var.environment
  ecr_repo_name = var.ecr_repo_name
}

module "apigw" {
  source          = "./modules/apigw"
  project         = var.project
  environment     = var.environment
  apigw_name      = var.apigw_name
  apigw_stage_name = var.apigw_stage_name
}
