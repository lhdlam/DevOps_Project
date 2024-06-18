variable "project_name" {}
variable "project_env" {}
variable "vpc" {}

variable "public_ingress_rules" {
  type = list(object({
    description      = string
    from_port        = number
    to_port          = number
    protocol         = string                 # tcp / udp / -1 for both
    cidr_blocks      = list(string)           # ["0.0.0.0/0"]
    ipv6_cidr_blocks = optional(list(string)) # ["::/0"]
    security_groups  = optional(list(string))
  }))
}

variable "public_egress_rules" {
  type = list(object({
    description      = string
    from_port        = number
    to_port          = number
    protocol         = string                 # tcp / udp / -1 for both
    cidr_blocks      = list(string)           # ["0.0.0.0/0"]
    ipv6_cidr_blocks = optional(list(string)) # ["::/0"]
    security_groups  = optional(list(string))
  }))

  default = [
    {
      description      = "Accept outbound all traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      security_groups  = []
    },
    {
      description      = "Accept outbound all traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = []
      ipv6_cidr_blocks = ["::/0"]
      security_groups  = []
    },
  ]
}

variable "private_ingress_rules" {
  type = list(object({
    description      = string
    from_port        = number
    to_port          = number
    protocol         = string                 # tcp / udp / -1 for both
    cidr_blocks      = list(string)           # ["0.0.0.0/0"]
    ipv6_cidr_blocks = optional(list(string)) # ["::/0"]
    security_groups  = optional(list(string))
  }))
  default = []
}

variable "private_egress_rules" {
  type = list(object({
    description      = string
    from_port        = number
    to_port          = number
    protocol         = string                 # tcp / udp / -1 for both
    cidr_blocks      = list(string)           # ["0.0.0.0/0"]
    ipv6_cidr_blocks = optional(list(string)) # ["::/0"]
    security_groups  = optional(list(string))
  }))

  default = [
    {
      description      = "Accept outbound all traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      security_groups  = []
    },
    {
      description      = "Accept outbound all traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = []
      ipv6_cidr_blocks = ["::/0"]
      security_groups  = []
    },
  ]
}
variable "tags" {}
