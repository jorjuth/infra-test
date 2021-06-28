
data "aws_availability_zones" "current" {
  state = "available"
}

data "aws_region" "current" {}

locals {
  vpc_endpoints = [
    "ssm",
    "secretsmanager",
    "ecr.api",
    "ecr.dkr",
    "ec2",
    "ec2messages",
    "ssmmessages",
    "logs",
    "events",
    "monitoring",
    "ecs",
    "ecs-agent",
    "ecs-telemetry",
  ]
}

resource "aws_vpc_endpoint" "this" {
  for_each = toset(local.vpc_endpoints)

  vpc_id              = var.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.key}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.subnets
  security_group_ids  = [aws_security_group.this.id]
  private_dns_enabled = true
  tags = merge(
    var.tags,
    {
      Name = "${terraform.workspace} ${data.aws_region.current.name} ${var.project_name} ${title(each.key)}"
    }
  )
}

resource "aws_security_group" "this" {
  name        = "VPC endpoints"
  description = "Allow communication to VPC endpoints"
  vpc_id      = var.vpc.id

  dynamic "ingress" {
    for_each = {
      443 : "HTTPS VPC endpoint"
      587 : "SMTPS VPC endpoint"
    }

    content {
      description = ingress.value
      from_port   = ingress.key
      to_port     = ingress.key
      protocol    = "TCP"
      cidr_blocks = [var.vpc.cidr_block]
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${terraform.workspace} ${data.aws_region.current.name} VPC Endpoints"
    }
  )
}
