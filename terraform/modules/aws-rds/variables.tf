
variable "rds_cluster" {
  description = "True is RDS cluster to be deployed"
  type        = bool
  default     = false
}

variable "rds_type" {
  description = "DB cluster parameters"
  type = object({
    instance_class               = string
    engine                       = string
    version                      = string
    family                       = string
    parameter_group_name         = string
    preferred_backup_window      = string
    backup_retention_period      = number
    preferred_maintenance_window = string
    instance_count               = number
    cloudwatch_log_exports       = list(string)
  })
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "rds_name" {
  description = "DB name"
  type        = string
}

variable "rds_subnet_ids" {
  description = "Subnet IDs"
  type        = list(string)
}

variable "adb_vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "rds_parameter_group" {
  description = "RDS parameter group"
  type        = list(map(string))
  default     = []
}

variable "kms_key" {
  description = "KMS key"
  type = object({
    id  = string
    arn = string
  })
}

variable "tags" {
  type = map(string)
}

variable "performance_insights_enabled" {
  type    = bool
  default = false
}

variable "cloudwatch_retention" {
  description = "Cloudwatch Logs - retention in days"
  type        = number
  default     = 0
}

variable "dbuser" {
  description = "DB admin username"
  type        = string
}

variable "dbpass" {
  description = "DB admin password"
  type        = string
}

variable "dbname" {
  description = "DB name"
  type        = string
}

variable "app_security_group_id" {
  description = "App security group"
  type        = string
}
