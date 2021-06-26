
variable "tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}

variable "vpc_cidr" {
  description = "VPC CIDR address"
  type        = string
}

/*
variable "vpc_cidr_shift" {
  type = string
}
*/

variable "tenancy" {
  description = "Tenancy - dedicated or default of host"
  type        = string
  default     = "default"
}

variable "single_az_cidr_shift" {
  description = "Single AZ CIDR shift"
  type        = number
}

variable "multi_az_cidr_shift" {
  description = "Multi AZ CIDR shift"
  type        = number
}

variable "enable_dns_hostnames" {
  description = "Do we allow dns hostname"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Dns support"
  type        = bool
  default     = true
}

variable "enable_ipv6" {
  description = "Enable the new fangled IPV6"
  type        = bool
  default     = false
}

variable "vpc_type" {
  description = "Public / Private"
  type        = string
}

variable "map_public_ip_on_launch" {
  description = "Map public IP to subnet"
  type        = bool
  default     = false
}

/*
variable "vpcname" {
  description = "VPC Name"
  type        = string
  default     = "monkey"
}

variable "vpc_region" {
  description = "the region"
  type        = string
  default     = "eu-central-1"
}

variable "vpc_prov" {
  description = "provider"
  type        = string
  default     = "frankfurt"
}

variable "az_count" {
  description = "How many vpcs are required"
  type        = number
  default     = 3
}

variable "cidr_shift" {
  description = "How many bits to add to the CIDR subnet"
  type        = number
  default     = 3
}

variable "priv_net" {
  description = "Enable private network"
  type        = bool
  default     = true
}

variable "pub_net" {
  description = "Enable public network"
  type        = bool
  default     = false
}

variable "tgw_enable" {
  description = "Enable Transit Gateway"
  type        = bool
  default     = false
}

variable "multi_az_priv_subnets" {
  description = "Multi AZ private subnets"
  type = object({
    name       = list(string)
    cidr_shift = number
  })
  default = {
    name       = []
    cidr_shift = 0
  }
}

variable "multi_az_pub_subnets" {
  description = "Multi AZ public subnets"
  type = object({
    name       = list(string)
    cidr_shift = number
  })
  default = {
    name       = []
    cidr_shift = 0
  }
}

variable "single_az_priv_subnets" {
  description = "Single AZ private subnets"
  type = object({
    name       = list(string)
    cidr_shift = number
  })
  default = {
    name       = []
    cidr_shift = 0
  }
}

variable "single_az_pub_subnets" {
  description = "Single AZ public subnets"
  type = object({
    name       = list(string)
    cidr_shift = number
  })
  default = {
    name       = []
    cidr_shift = 0
  }
}

variable "net_name" {
  description = "VPC name"
  type        = string
  default     = ""
}

variable "idm_aevi_common_tags" {
  description = "IDM Aevi common tags"
  type        = map(string)
}
*/

# locals {
#   az_count =  length(data.aws_availability_zones.available.names) > 2 ? 3:2
# }
# */

variable "project_name" {
  type = string
}

variable "log_bucket_arn" {
  description = "S3 bucket ARN for VPC Flow log"
  type        = string
  default     = ""
}
