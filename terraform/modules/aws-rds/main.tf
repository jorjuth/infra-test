
######
# Security groups
#####

resource "aws_security_group_rule" "this_self" {
  for_each          = toset(["ingress", "egress"])
  security_group_id = aws_security_group.this.id
  type              = each.key
  description       = "RDS to itself"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  self              = true
}

resource "aws_security_group_rule" "this_app" {
  security_group_id        = aws_security_group.this.id
  type                     = "ingress"
  description              = "Incoming app communication"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = var.app_security_group_id
}

resource "aws_security_group" "this" {
  name        = "rds-${var.rds_name}-${terraform.workspace}-security-group"
  description = "Allow PSQL internal communication"
  vpc_id      = var.adb_vpc_id

  tags = {
    Name = "RDS security group - ${var.rds_name}"
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
      Name = "RDS subnet group - ${var.rds_name}"
  })
}

resource "aws_rds_cluster_parameter_group" "this" {
  count = var.rds_cluster ? 1 : 0

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
      Name = "RDS parameter group - ${var.rds_name}"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_rds_cluster" "this" {
  count = var.rds_cluster ? 1 : 0

  cluster_identifier   = "${var.rds_name}-${terraform.workspace}-cluster"
  db_subnet_group_name = aws_db_subnet_group.this.name
  engine               = var.rds_type.engine
  engine_version       = var.rds_type.version

  master_username = var.dbuser
  master_password = var.dbpass

  deletion_protection = var.deletion_protection
  kms_key_id          = var.kms_key.arn
  storage_encrypted   = var.kms_key.arn != "" ? true : false

  db_cluster_parameter_group_name = try(aws_rds_cluster_parameter_group.this[0].id, null)

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
  count = var.rds_cluster ? var.rds_type.instance_count : 0

  cluster_identifier   = aws_rds_cluster.this[0].id
  identifier           = "${var.rds_name}-${terraform.workspace}-${count.index}"
  instance_class       = var.rds_type.instance_class
  db_subnet_group_name = aws_rds_cluster.this[0].db_subnet_group_name
  engine               = aws_rds_cluster.this[0].engine
  engine_version       = aws_rds_cluster.this[0].engine_version

  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_kms_key_id = aws_rds_cluster.this[0].kms_key_id

  apply_immediately = true

  lifecycle {
    ignore_changes = [engine_version]
  }

  tags = var.tags
}

resource "aws_db_instance" "this" {
  count = var.rds_cluster ? 0 : 1

  allocated_storage    = 10
  identifier           = "${var.rds_name}-${terraform.workspace}"
  instance_class       = var.rds_type.instance_class
  db_subnet_group_name = aws_db_subnet_group.this.name
  engine               = var.rds_type.engine
  engine_version       = var.rds_type.version

  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_kms_key_id = var.kms_key.arn
  enabled_cloudwatch_logs_exports = var.rds_type.cloudwatch_log_exports

  username = var.dbuser
  password = var.dbpass
  name     = var.dbname

  deletion_protection = var.deletion_protection
  kms_key_id          = var.kms_key.arn
  storage_encrypted   = var.kms_key.arn != "" ? true : false

  backup_window           = var.rds_type.preferred_backup_window
  backup_retention_period = var.rds_type.backup_retention_period
  maintenance_window      = var.rds_type.preferred_maintenance_window

  skip_final_snapshot         = true
  apply_immediately           = true
  allow_major_version_upgrade = true

  vpc_security_group_ids = [aws_security_group.this.id]

  lifecycle {
    ignore_changes = [engine_version]
  }

  tags = var.tags
}

######
# Cloudwatch log groups
######

/*
resource "aws_cloudwatch_log_group" "this" {
  for_each = {
    for i in var.rds_type.cloudwatch_log_exports && var.rds_cluster)

  name       = "/aws/rds/cluster/${aws_rds_cluster.this[0].cluster_identifier}/${each.key}"
  kms_key_id = var.kms_key.arn

  retention_in_days = var.cloudwatch_retention
  tags              = var.tags
}
*/
