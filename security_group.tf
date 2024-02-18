# TODO: モジュール化検討すること
resource "aws_security_group" "ingress-1a" {
  name = "ingress-1a"
  vpc_id = aws_vpc.sbcntrVPC.id
}

resource "aws_security_group_rule" "ingress-1a-ingress" {
  type = "ingress"
  from_port = "80"
  to_port = "80"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ingress-1a.id
}

resource "aws_security_group_rule" "ingress-1a-engress" {
  type = "engress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.ingress-1a.id
}

resource "aws_security_group" "frontend-app-1a" {
  name = "frontend-app-1a"
  vpc_id = aws_vpc.sbcntrVPC.id
}

resource "aws_security_group_rule" "frontend-app-1a-ingress" {
  type = "ingress"
  from_port = "80"
  to_port = "80"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.frontend-app-1a.id
}

resource "aws_security_group_rule" "frontend-app-1a-engress" {
  type = "engress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.frontend-app-1a.id
}

resource "aws_security_group" "internal-alb-1a" {
  name = "internal-alb-1a"
  vpc_id = aws_vpc.sbcntrVPC.id
}

resource "aws_security_group_rule" "internal-alb-1a-ingress" {
  type = "ingress"
  from_port = "80"
  to_port = "80"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.internal-alb-1a.id
}

resource "aws_security_group_rule" "internal-alb-1a-engress" {
  type = "engress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.internal-alb-1a.id
}

resource "aws_security_group" "backend-app-1a" {
  name = "backend-app-1a"
  vpc_id = aws_vpc.sbcntrVPC.id
}

resource "aws_security_group_rule" "backend-app-1a-ingress" {
  type = "ingress"
  from_port = "80"
  to_port = "80"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.backend-app-1a.id
}

resource "aws_security_group_rule" "backend-app-1a-engress" {
  type = "engress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.backend-app-1a.id
}

resource "aws_security_group" "db-1a" {
  name = "db-1a"
  vpc_id = aws_vpc.sbcntrVPC.id
}

resource "aws_security_group_rule" "db-1a-ingress" {
  type = "ingress"
  from_port = "3306"
  to_port = "3306"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.db-1a.id
}

resource "aws_security_group_rule" "db-1a-engress" {
  type = "engress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.db-1a.id
}

resource "aws_security_group" "management-1a" {
  name = "management-1a"
  vpc_id = aws_vpc.sbcntrVPC.id
}

resource "aws_security_group_rule" "management-1a-http-ingress" {
  type = "ingress"
  from_port = "80"
  to_port = "80"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.management-1a.id
}

resource "aws_security_group_rule" "management-1a-db-ingress" {
  type = "ingress"
  from_port = "3306"
  to_port = "3306"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.management-1a.id
}

resource "aws_security_group_rule" "management-1a-engress" {
  type = "engress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.management-1a.id
}
