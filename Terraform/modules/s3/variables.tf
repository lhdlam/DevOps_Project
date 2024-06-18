variable "project_name" {}
variable "project_env" {}
variable "s3_origin_id" {}

variable "object_ownership" {
  type    = string
  default = ""
}

variable "enable_trigger" {
  type    = bool
  default = false
}

variable "tags" {}
