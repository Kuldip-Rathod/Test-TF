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
