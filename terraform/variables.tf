
variable "common_tags" {
  description = "Additional resource tags"
  type        = map(string)
  default = {
    Project = "Infra Test"
  }
}

variable "aws_account" {
  description = "AWS account"
  type        = map(string)
  default = {
    prod = "aevi-sandbox"
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = map(string)
  default = {
    prod = "eu-central-1"
  }
}

variable "project_name" {
  type    = string
  default = "Infra Test"
}

variable "project_prefix" {
  type    = string
  default = "infra-test"
}

variable "vpc_network" {
  description = "VPC network"
  type        = map(string)
  default = {
    prod = "10.111.108.0/22"
  }
}

variable "vpc_net_shift" {
  type = map(number)
  default = {
    prod = 4
  }
}

variable "cloudwatch_retention" {
  description = "Cloudwatch Logs retention in days"
  type        = map(number)
  default = {
    prod = 180
  }
}

variable "rds_performance_insights_enabled" {
  description = "RDS Performance Insights enabled"
  type        = map(bool)
  default = {
    prod = true
  }
}

variable "rds_parameter_group" {
  description = "RDS parameter group"
  type        = list(map(string))
  default     = []
}

variable "ecr_repositories" {
  description = "ECR repository"
  type        = string
  default     = "member-api"
}

variable "docker_image" {
  description = "Docker Hub info"
  type        = map(string)
  default = {
    name = "infrastructure-test"
    repo = "eldertech"
    tag  = "latest"
  }
}
