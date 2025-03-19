resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-${var.alb_name}"
  internal           = var.alb_internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  
  enable_deletion_protection = var.enable_deletion_protection
  enable_http2               = var.enable_http2
  
  tags = merge(
    var.default_tags,
    {
      Name = "${var.project_name}-${var.environment}-alb"
    }
  )
}


# Target Group for Fargate Service
resource "aws_lb_target_group" "app" {
  name        = "${var.project_name}-${var.environment}-${var.target_group_name}"
  port        = var.target_group_port
  protocol    = var.target_group_protocol
  vpc_id      = local.actual_vpc_id
  target_type = var.target_type

  deregistration_delay = var.deregistration_delay
  slow_start           = var.slow_start

  health_check {
    enabled             = var.health_check["enabled"]
    healthy_threshold   = var.health_check["healthy_threshold"]
    interval            = var.health_check["interval"]
    matcher             = var.health_check["matcher"]
    path                = var.health_check["path"]
    port                = var.health_check["port"]
    protocol            = var.health_check["protocol"]
    timeout             = var.health_check["timeout"]
    unhealthy_threshold = var.health_check["unhealthy_threshold"]
  }

  stickiness {
    type            = var.stickiness["type"]
    cookie_name     = var.stickiness["cookie_name"]
    cookie_duration = var.stickiness["cookie_duration"]
    enabled         = var.stickiness["enabled"]
  }

  tags = merge(
    var.default_tags,
    {
      Name = "${var.project_name}-${var.environment}-${var.target_group_name}"
    }
  )
}

# HTTP Listener (Port 80)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.http_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }

  lifecycle {
    ignore_changes = [default_action]
  }

  tags = var.default_tags
}

# Create a separate HTTPS redirect rule that depends on ECS service
resource "aws_lb_listener_rule" "http_to_https_redirect" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 1

  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  action {
    type = "redirect"
    redirect {
      port        = var.https_port
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  # This makes the redirect rule wait for ECS service to be ready
  depends_on = [aws_ecs_service.main]

  tags = var.default_tags
}

# HTTPS Listener (Port 443)
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.https_port
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }

  tags = var.default_tags
}