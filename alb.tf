resource "aws_lb" "main" {
  count              = var.enable_load_balancer ? 1 : 0
  name               = "${var.app_name}-alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb[0].id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = false

  tags = merge(
    var.tags,
    {
      Name = "${var.app_name}-alb-${var.environment}"
    }
  )
}

resource "aws_lb_target_group" "main" {
  count            = var.enable_load_balancer ? 1 : 0
  name             = "${var.app_name}-tg-${var.environment}"
  port             = var.container_port
  protocol         = "HTTP"
  vpc_id           = aws_vpc.main.id
  target_type      = "ip"

  health_check {
  healthy_threshold   = 2
  unhealthy_threshold = 2
  timeout             = 3
  interval            = 30
  path                = "/"
  matcher             = "200"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.app_name}-tg-${var.environment}"
    }
  )
}

resource "aws_lb_listener" "main" {
  count              = var.enable_load_balancer ? 1 : 0
  load_balancer_arn  = aws_lb.main[0].arn
  port               = "80"
  protocol           = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[0].arn
  }
}
