
/*
variable "nlb_protocol" {
  default = "TCP"
}

resource "aws_lb" "nlb" {
  name               = "nlb-${var.project_prefix}"
  subnets            = module.member_api_vpc.subnet_app.*.id
  load_balancer_type = "network"
  internal           = true
}

resource "aws_lb_target_group" "nlb" {
  name        = "nlb-${var.project_prefix}"
  port        = var.app_port
  protocol    = var.nlb_protocol
  vpc_id      = module.member_api_vpc.vpc.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "2"
    interval            = "30"
    protocol            = var.alb_protocol
    path                = "/"
    unhealthy_threshold = "2"
  }
}

resource "aws_lb_listener" "nlb" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = var.app_port
  protocol          = var.nlb_protocol

  default_action {
    target_group_arn = aws_lb_target_group.nlb.arn
    type             = "forward"
  }
}
*/
