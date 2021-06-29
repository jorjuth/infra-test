
resource "aws_cloudwatch_log_group" "ecs" {
  name = "/ecs/${var.project_prefix}"
  #kms_key_id = aws_kms_key.this.arn

  tags = merge(
    var.common_tags,
    {
      Name        = var.project_name
      Environment = terraform.workspace
    }
  )
}

resource "aws_iam_role" "ecs" {
  name = "ecs-${var.project_prefix}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs2" {
  name = aws_iam_role.ecs.name
  role = aws_iam_role.ecs.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_ecs_cluster" "this" {
  name               = var.project_prefix
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.project_prefix
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs.arn
  task_role_arn            = aws_iam_role.ecs.arn

  cpu    = "256"
  memory = "512"

  container_definitions = <<EOF
[
  {
    "name": "${var.project_prefix}",
    "image": "${module.member_api_ecr.repository.repository_url}:${var.docker_image.tag}",
    "cpu": 0,
    "memory": 128,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${data.aws_region.current.name}",
        "awslogs-group": "${aws_cloudwatch_log_group.ecs.name}",
        "awslogs-stream-prefix": "complete-ecs"
      }
    },
    "environment": [
      {
        "name": "DB_HOST",
        "value": "${module.member_api_pgsql.instance.address}"
      },
      {
        "name": "PSQL_USER",
        "value": "${module.member_api_pgsql.instance.username}"
      },
      {
        "name": "PSQL_PASS",
        "value": "${module.member_api_pgsql.instance.password}"
      },
      {
        "name": "PSQL_DBNAME",
        "value": "${module.member_api_pgsql.instance.dbname}"
      },
      {
        "name": "PSQL_PORT",
        "value": "${module.member_api_pgsql.instance.port}"
      }
    ],
    "portMappings":[
      {
        "containerPort": ${var.app_port},
        "protocol": "tcp",
        "hostPort": ${var.app_port}
      }
    ]
  }
]
EOF
}

resource "aws_ecs_service" "this" {
  name            = var.project_prefix
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.member_api_vpc.subnet_app.*.id
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_ext.id
    container_name   = var.project_prefix
    container_port   = var.app_port
  }

  /*
  load_balancer {
    target_group_arn = aws_lb_target_group.alb_int.id
    container_name   = var.project_prefix
    container_port   = var.app_port
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.nlb.id
    container_name   = var.project_prefix
    container_port   = var.app_port
  }
  */

  tags = merge(
    var.common_tags,
    {
      Environment = terraform.workspace
  })
}

resource "aws_security_group_rule" "this_sg" {
  for_each = {
    "RDS" = {
      type                     = "egress"
      from_port                = 5432
      to_port                  = 5432
      source_security_group_id = module.member_api_pgsql.sg_rds_id
    }
    "VPC endpoints" = {
      type                     = "egress"
      from_port                = 443
      to_port                  = 443
      source_security_group_id = module.member_api_vpcendpoints.sg_vpc_endpoints_id
    }
    "external ALB" = {
      type                     = "ingress"
      from_port                = var.app_port
      to_port                  = var.app_port
      source_security_group_id = aws_security_group.alb.id
    }
  }

  security_group_id        = aws_security_group.ecs.id
  type                     = each.value.type
  description              = each.key
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = "tcp"
  source_security_group_id = each.value.source_security_group_id
}

resource "aws_security_group_rule" "s3" {
  security_group_id = aws_security_group.ecs.id
  type              = "egress"
  description       = "S3 endpoints"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  prefix_list_ids   = [module.member_api_vpc.s3_vpc_endpoint.pl]
}

resource "aws_security_group" "ecs" {
  name        = "ecs-${var.project_name}-${terraform.workspace}-security-group"
  description = "Allow ${var.project_name} internal communication"
  vpc_id      = module.member_api_vpc.vpc.id

  tags = {
    Name = "ECS security group - ${var.project_name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}
