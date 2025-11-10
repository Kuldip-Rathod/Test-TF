variable "project" {}
variable "environment" {}

variable "db_name" {}
variable "db_username" {}
variable "db_password" {}
variable "db_instance_class" {}
variable "db_allocated_storage" {}
variable "db_engine_version" {}

variable "vpc_id" {}
variable "subnet_ids" {
  type = list(string)
}
