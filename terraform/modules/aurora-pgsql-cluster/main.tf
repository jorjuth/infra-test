
resource "random_password" "this" {
  length  = 24
  special = false
}

######
# Security groups
#####

resource "aws_security_group_rule" "this" {
  type                     = "ingress"
  description              = "RDS to itself"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.this.id
  security_group_id        = aws_security_group.this.id
}

resource "aws_security_group" "this" {
  name        = "${var.rds_name}-${terraform.workspace}-security-group"
  description = "Allow PSQL internal communication"
  vpc_id      = var.adb_vpc_id

  tags = {
    Name = "RDS security group - ${upper(var.rds_name)}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

######
# DB stuff
######

resource "aws_db_subnet_group" "this" {
  name       = "${var.rds_name}-${terraform.workspace}-subnet-group"
  subnet_ids = var.rds_subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "RDS subnet group - ${upper(var.rds_name)}"
  })
}

resource "aws_rds_cluster_parameter_group" "this" {
  name_prefix = "${lower(var.rds_name)}-"
  family      = var.rds_type.family
  description = "RDS cluster parameter group - ${var.rds_name}"

  dynamic "parameter" {
    for_each = var.rds_parameter_group

    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }
  tags = merge(
    var.tags,
    {
      Name = "RDS parameter group - ${upper(var.rds_name)}"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_rds_cluster" "this" {
  cluster_identifier   = "${var.rds_name}-${terraform.workspace}-cluster"
  db_subnet_group_name = aws_db_subnet_group.this.name
  engine               = var.rds_type.engine
  engine_version       = var.rds_type.version

  master_username = "rds_admin"
  master_password = random_password.this.result

  deletion_protection = var.deletion_protection
  kms_key_id          = var.kms_key.arn
  storage_encrypted   = var.kms_key.arn != "" ? true : false

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.id

  enabled_cloudwatch_logs_exports = var.rds_type.cloudwatch_log_exports

  preferred_backup_window      = var.rds_type.preferred_backup_window
  backup_retention_period      = var.rds_type.backup_retention_period
  preferred_maintenance_window = var.rds_type.preferred_maintenance_window

  skip_final_snapshot         = true
  apply_immediately           = true
  allow_major_version_upgrade = true

  vpc_security_group_ids = [aws_security_group.this.id]

  tags = var.tags
}

resource "aws_rds_cluster_instance" "this" {
  count = var.rds_type.instance_count

  cluster_identifier   = aws_rds_cluster.this.id
  identifier           = "${var.rds_name}-${terraform.workspace}-${count.index}"
  instance_class       = var.rds_type.instance_class
  db_subnet_group_name = aws_rds_cluster.this.db_subnet_group_name
  engine               = aws_rds_cluster.this.engine
  engine_version       = aws_rds_cluster.this.engine_version

  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_kms_key_id = aws_rds_cluster.this.kms_key_id

  apply_immediately = true

  lifecycle {
    ignore_changes = [engine_version]
  }

  tags = var.tags
}

######
# Cloudwatch log groups
######

resource "aws_cloudwatch_log_group" "this" {
  for_each = toset(var.rds_type.cloudwatch_log_exports)

  name       = "/aws/rds/cluster/${aws_rds_cluster.this.cluster_identifier}/${each.key}"
  kms_key_id = var.kms_key.arn

  retention_in_days = var.cloudwatch_retention
  tags              = var.tags
}
