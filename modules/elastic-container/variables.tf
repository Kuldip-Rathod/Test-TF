variable "project" {}
variable "environment" {}
variable "service_name" {}

variable "container_name" {}
variable "container_port" { type = number }
variable "desired_count"  { type = number }
variable "task_cpu"       { type = number }
variable "task_memory"    { type = number }
variable "health_check_path" {}

variable "ecr_repo_url" {}
variable "image_tag" {}

variable "vpc_id" {}
variable "public_subnet_ids" { type = list(string) }
