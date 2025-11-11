project     = "Test"
environment = "dev"
aws_region  = "us-east-2"

vpc_cidr = "10.0.0.0/16"

public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

availability_zones = ["us-east-2a", "us-east-2b"]

ami_id        = "ami-0f5fcdfbd140e4ab7"
instance_type = "t3.medium"
key_name      = "KD_test"

#RDS
db_name             = "newDB"
db_username         = "test"
db_password         = "ft!&gft234HCVgfs"
db_instance_class   = "db.t3.small"
db_allocated_storage = 20
db_engine_version   = "16.9"

#S3
s3_bucket_name = "test-dev-files-qqwwee"

#ECR
ecr_repo_name = "privaterepo"

#gateway
apigw_name       = "test-api"
apigw_stage_name = "v1"

# ECS + ALB config
service_name      = "api"
container_name    = "api"
container_port    = 8000
desired_count     = 1
task_cpu          = 512
task_memory       = 1024
health_check_path = "/health"

ecr_repo_url = "414819400975.dkr.ecr.us-east-2.amazonaws.com/test-dev-ecr-privaterepo"
image_tag    = "latest"