
module "network" {
  source             = "./modules/network"
  project            = var.project
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
}

# module "server" {
#   source        = "./modules/server"
#   project       = var.project
#   environment   = var.environment
#   ami_id        = var.ami_id
#   instance_type = var.instance_type
#   key_name      = var.key_name
#   subnet_id     = module.network.public_subnet_ids[0]
#   vpc_id        = module.network.vpc_id
# }

# module "database" {
#   source              = "./modules/database"
#   project             = var.project
#   environment         = var.environment

#   db_name             = var.db_name
#   db_username         = var.db_username
#   db_password         = var.db_password
#   db_instance_class   = var.db_instance_class
#   db_allocated_storage = var.db_allocated_storage
#   db_engine_version   = var.db_engine_version

#   vpc_id              = module.network.vpc_id
#   subnet_ids          = module.network.public_subnet_ids
# }

# module "s3" {
#   source        = "./modules/s3"
#   project       = var.project
#   environment   = var.environment
#   s3_bucket_name = var.s3_bucket_name
# }

# module "registry" {
#   source        = "./modules/registry"
#   project       = var.project
#   environment   = var.environment
#   ecr_repo_name = var.ecr_repo_name
# }

# module "gateway" {
#   source          = "./modules/gateway"
#   project         = var.project
#   environment     = var.environment
#   apigw_name      = var.apigw_name
#   apigw_stage_name = var.apigw_stage_name
# }

# module "elastic_container" {
#   source            = "./modules/elastic-container"

#   project           = var.project
#   environment       = var.environment
#   service_name      = var.service_name

#   container_name    = var.container_name
#   container_port    = var.container_port
#   desired_count     = var.desired_count
#   task_cpu          = var.task_cpu
#   task_memory       = var.task_memory
#   health_check_path = var.health_check_path

#   ecr_repo_url      = var.ecr_repo_url
#   image_tag         = var.image_tag

#   vpc_id            = module.network.vpc_id
#   public_subnet_ids = module.network.public_subnet_ids
# }
