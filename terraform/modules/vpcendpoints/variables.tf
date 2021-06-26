
variable "tags" {
  description = "Additional resource tags"
  type        = map(string)
}

variable "vpc" {
  description = "VPC"
  type = object({
    id         = string,
    cidr_block = string
  })
}

variable "subnets" {
  description = "VPC subnets"
  type        = list(string)
}

variable "project_name" {
  type = string
}
