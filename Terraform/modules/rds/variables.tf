variable "project_name" {}
variable "project_env" {}
variable "private_subnets" {}
variable "db_family" {}
variable "db_engine" {}
variable "db_engine_version" {}
variable "db_username" {}
variable "db_password" {}
variable "db_port" {}
variable "db_instance_class" {}
variable "db_allocated_storage" {}
variable "security_groups" {}
variable "tags" {}
variable "snapshot_identifier" {}

variable "rds_parameters" {
  type = map(string)
}
