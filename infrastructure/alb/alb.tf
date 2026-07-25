# ==============================================================================
# Enterprise AWS Three-Tier Architecture - Application Load Balancer (ALB)
# ==============================================================================

resource "aws_lb" "external_alb" {
  name               = "banking-external-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [var.public_subnet_1a_id, var.public_subnet_1b_id]

  enable_deletion_protection = false

  tags = {
    Name        = "banking-external-alb"
    Environment = "production"
  }
}

resource "aws_lb_target_group" "web_tg" {
  name     = "banking-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    path                = "/healthz"
    protocol            = "HTTP"
    port                = "80"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.external_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
