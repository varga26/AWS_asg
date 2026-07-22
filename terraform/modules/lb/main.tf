resource "aws_lb" "lb" {
  name               = "load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.lb_sg_id]
  subnets            = [var.public_subnet_1_id, var.public_subnet_2_id]

  tags = {
    Name = "load-balancer"
  }
}

resource "aws_lb_target_group" "openwebui_tg" {
  name_prefix = "owui-"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    protocol            = "HTTP"
    path                = "/health"
    matcher             = "200-399"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.openwebui_tg.arn
  }
}

resource "aws_lb" "ollama_internal" {
  name               = "ollama-internal"
  internal           = true
  load_balancer_type = "network"
  subnets            = [var.private_subnet_1_id, var.private_subnet_2_id]

  tags = {
    Name = "ollama-internal"
  }
}

resource "aws_lb_target_group" "ollama_tg" {
  name        = "ollama-target-group"
  port        = 11434
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    protocol            = "TCP"
    port                = "11434"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
  }
}

resource "aws_lb_listener" "ollama_listener" {
  load_balancer_arn = aws_lb.ollama_internal.arn
  port              = 11434
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ollama_tg.arn
  }
}

resource "aws_lb_target_group" "grafana_tg" {
  name        = "grafana-target-group"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    protocol            = "HTTP"
    path                = "/api/health"
    matcher             = "200-399"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group_attachment" "grafana" {
  target_group_arn = aws_lb_target_group.grafana_tg.arn
  target_id        = var.grafana_instance_id
  port             = 3000
}

resource "aws_lb_listener" "grafana_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 3000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana_tg.arn
  }
}
