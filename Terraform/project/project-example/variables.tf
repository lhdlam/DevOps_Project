variable "name" {
  default = "default"
}

variable "project_name" {
  type        = string
  description = "Name of project"
}

variable "project_aws_profile" {
  type        = string
  description = "AWS profile name"
}

variable "project_aws_region" {
  type        = string
  description = "AWS region"
}


variable "vpc_cidr" {
  type        = string
  description = "Vpc cidr block"
}

variable "workspace" {
  type = string
  default = "terraform"
}