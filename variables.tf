variable "project" {}
variable "environment" {}
variable "aws_region" {}

# VPC
variable "vpc_cidr" {}
variable "public_subnets" {
  type = list(string)
}
variable "private_subnets" {
  type = list(string)
}
variable "availability_zones" {
  type = list(string)
}

# EC2
variable "instance_type" {}
variable "key_name" {}
variable "ami_id" {}

# RDS
variable "db_name" {}
variable "db_username" {}
variable "db_password" {}
variable "db_instance_class" {}
variable "db_allocated_storage" {}
variable "db_engine_version" {}

#s3
variable "s3_bucket_name" {}

#ECR
variable "ecr_repo_name" {}

#gateway
variable "apigw_name" {}
variable "apigw_stage_name" {}

# ECS + ALB
variable "service_name" {}
variable "container_name" {}
variable "container_port" { type = number }
variable "desired_count"  { type = number }
variable "task_cpu"       { type = number }
variable "task_memory"    { type = number }
variable "health_check_path" {}

# ECR image
variable "ecr_repo_url" {}   
variable "image_tag"    {}   
