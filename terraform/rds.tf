
module "member_api_pgsql" {
  source = "./modules/aurora-pgsql-cluster/"

  rds_type = {
    instance_class               = "db.r5.large"
    engine                       = "aurora-postgresql"
    version                      = "12.6"
    family                       = "aurora-postgresql12"
    parameter_group_name         = "pg12"
    preferred_backup_window      = "00:30-02:00"
    backup_retention_period      = 14
    preferred_maintenance_window = "tue:02:15-tue:03:45"
    instance_count               = terraform.workspace == "prod" ? 2 : 1
    cloudwatch_log_exports       = []
  }

  tags                         = var.common_tags
  rds_name                     = var.project_prefix
  rds_subnet_ids               = module.member_api_vpc.subnet_rds.*.id
  adb_vpc_id                   = module.member_api_vpc.vpc.id
  performance_insights_enabled = lookup(var.rds_performance_insights_enabled, terraform.workspace, false)
  cloudwatch_retention         = lookup(var.cloudwatch_retention, terraform.workspace, 0)
  rds_parameter_group          = var.rds_parameter_group
  deletion_protection          = false
  kms_key = {
    id  = aws_kms_key.this.id
    arn = aws_kms_key.this.arn
  }
}
