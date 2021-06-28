
resource "aws_security_group" "alb" {
  name        = "alb-${var.project_name}-${terraform.workspace}-security-group"
  description = "Allow ${var.project_name} internal communication"
  vpc_id      = module.member_api_vpc.vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = var.app_port
    to_port     = var.app_port
    cidr_blocks = ["0.0.0.0/0"]
    description = "From Internet"
  }

  egress {
    protocol        = "tcp"
    from_port       = var.app_port
    to_port         = var.app_port
    security_groups = [aws_security_group.ecs.id]
    description     = "To ECS"
  }

  tags = {
    Name = "ALB security group - ${var.project_name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "alb" {
  name            = "ext-${var.project_prefix}"
  subnets         = module.member_api_vpc.subnet_dmz.*.id
  security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_target_group" "alb" {
  name        = var.project_prefix
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = module.member_api_vpc.vpc.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

resource "aws_lb_listener" "alb" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.app_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.alb.arn
    type             = "forward"
  }
}
