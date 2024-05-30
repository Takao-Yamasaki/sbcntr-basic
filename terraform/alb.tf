# 内部向けALB(Backend)
resource "aws_lb" "sbcntr-alb-internal" {
  name               = "sbcntr-alb-internal"
  load_balancer_type = "application"
  # 内部向けALB
  internal = true
  # ipv4を指定
  ip_address_type = "ipv4"
  security_groups = [
    aws_security_group.sbcntr-sg-internal.id
  ]
  subnets = [
    aws_subnet.sbcntr-subnet-private-container-1a.id,
    aws_subnet.sbcntr-subnet-private-container-1c.id
  ]

  tags = {
    "Name" : "sbcntr-alb-internal"
  }
}

# プロダクションリスナー(Blue側に転送/Backend)
resource "aws_lb_listener" "blue" {
  load_balancer_arn = aws_lb.sbcntr-alb-internal.arn
  port              = 80
  protocol          = "HTTP"

  # リクエストをBlue側のターゲットグループに転送
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sbcntr-tg-sbcntrdemo-blue.arn
    order            = 1
  }
}

# テストリスナー(Green側に転送/Backend)
resource "aws_lb_listener" "green" {
  load_balancer_arn = aws_lb.sbcntr-alb-internal.arn
  # テストポートを指定
  port     = 10080
  protocol = "HTTP"

  # リクエストをBlue側のターゲットグループに転送
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sbcntr-tg-sbcntrdemo-green.arn
    order            = 1
  }
}

# ターゲットグループ(Blue側/Backend)
resource "aws_lb_target_group" "sbcntr-tg-sbcntrdemo-blue" {
  name             = "sbcntr-tg-sbcntrdemo-blue"
  target_type      = "ip"
  vpc_id           = aws_vpc.sbcntr-vpc.id
  port             = 80
  protocol         = "HTTP"
  protocol_version = "HTTP1"

  health_check {
    path                = "/healthcheck"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
    matcher             = 200
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  depends_on = [aws_lb.sbcntr-alb-internal]
}

# ターゲットグループ(Green側/Backend)
resource "aws_lb_target_group" "sbcntr-tg-sbcntrdemo-green" {
  name             = "sbcntr-tg-sbcntrdemo-green"
  target_type      = "ip"
  vpc_id           = aws_vpc.sbcntr-vpc.id
  port             = 80
  protocol         = "HTTP"
  protocol_version = "HTTP1"

  health_check {
    path                = "/healthcheck"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
    matcher             = 200
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  depends_on = [aws_lb.sbcntr-alb-internal]
}

# Ingress向けALB(Frontend)
resource "aws_lb" "sbcntr-alb-frontend" {
  name               = "sbcntr-alb-frontend"
  load_balancer_type = "application"
  # ipv4を指定
  ip_address_type = "ipv4"
  security_groups = [
    aws_security_group.sbcntr-sg-ingress.id
  ]
  subnets = [
    aws_subnet.sbcntr-subnet-public-ingress-1a.id,
    aws_subnet.sbcntr-subnet-public-ingress-1c.id
  ]

  tags = {
    "Name" : "sbcntr-alb-frontend"
  }
}

# ターゲットグループ(Frontend)
resource "aws_lb_target_group" "sbcntr-tg-frontend" {
  name             = "sbcntr-tg-frontend"
  target_type      = "ip"
  vpc_id           = aws_vpc.sbcntr-vpc.id
  port             = 80
  protocol         = "HTTP"
  protocol_version = "HTTP1"

  health_check {
    path                = "/healthcheck"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
    matcher             = 200
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  depends_on = [aws_lb.sbcntr-alb-frontend]
}

# リスナー(Frontend)
resource "aws_lb_listener" "sbcntr-frontend-listener1" {
  load_balancer_arn = aws_lb.sbcntr-alb-frontend.arn
  port              = 80
  protocol          = "HTTP"

  # リクエストをFrontend用のターゲットグループに転送
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sbcntr-tg-frontend.arn
    order            = 1
  }
}
