# インターネット公開用セキュリティグループ
resource "aws_security_group" "sbcntr-sg-ingress" {
  name        = "sbcntr-sg-ingress"
  vpc_id      = aws_vpc.sbcntr-vpc.id
  description = "security group for ingress"
  tags = {
    Name : "sbcntr-sg-ingress"
  }

  # -> IGW
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "from 0.0.0.0/0:80"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "allow all outbound traffic by default"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 管理用サーバー向けのセキュリティグループ
resource "aws_security_group" "sbcntr-sg-management" {
  name        = "sbcntr-sg-management"
  vpc_id      = aws_vpc.sbcntr-vpc.id
  description = "security group for management server"

  tags = {
    Name : "sbcntr-sg-management"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "allow all outbound traffic by default"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Backend Container用のセキュリティグループ
resource "aws_security_group" "sbcntr-sg-container" {
  name        = "sbcntr-sg-container"
  vpc_id      = aws_vpc.sbcntr-vpc.id
  description = "security group of backend app"

  tags = {
    Name : "sbcntr-sg-container"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "allow all outbound traffic by default"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# インバウンドルール(Internal LB -> Backend Container)
resource "aws_security_group_rule" "sbcntr-sg-container-from-sg-internal" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  # Internal LBからのアクセスを許可する
  source_security_group_id = aws_security_group.sbcntr-sg-internal.id
  security_group_id        = aws_security_group.sbcntr-sg-container.id
  description              = "HTTP for internal lb"
}

# Frontend Container用のセキュリティグループ
resource "aws_security_group" "sbcntr-sg-front-container" {
  name        = "sbcntr-sg-front-container"
  vpc_id      = aws_vpc.sbcntr-vpc.id
  description = "security group of front container app"

  tags = {
    Name : "sbcntr-sg-front-container"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "allow all outbound traffic by default"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# インバウンドルール(Internet LB -> Frontend Container)
resource "aws_security_group_rule" "sbcntr-sg-front-container-from-sg-ingress" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  # ingressからのアクセスを許可する
  source_security_group_id = aws_security_group.sbcntr-sg-ingress.id
  security_group_id        = aws_security_group.sbcntr-sg-front-container.id
  description              = "HTTP for Ingress"
}

# 内部用ロードバランサー用のセキュリティグループ
# テストリスナーのポートには、管理サーバーのみからアクセスできるようにする
resource "aws_security_group" "sbcntr-sg-internal" {
  name        = "sbcntr-sg-internal"
  vpc_id      = aws_vpc.sbcntr-vpc.id
  description = "security group for internal load balancer"
  tags = {
    Name : "sbcntr-sg-internal"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "allow all outbound traffic by default"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# インバウンドルール(Frontend Container -> Internal LB)
resource "aws_security_group_rule" "sbcntr-sg-internal-from-sg-front-container" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  # Frontendからアクセス許可
  source_security_group_id = aws_security_group.sbcntr-sg-front-container.id
  security_group_id        = aws_security_group.sbcntr-sg-internal.id
  description              = "HTTP for frontend container"
}

# インバウンドルール(Management Container -> Internal LB)
resource "aws_security_group_rule" "sbcntr-sg-internal-from-sg-management-tcp" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  # Managementからのアクセスを許可する
  source_security_group_id = aws_security_group.sbcntr-sg-management.id
  security_group_id        = aws_security_group.sbcntr-sg-internal.id
  description              = "HTTP for management server"
}

# テストポート向けインバウンドルール(Management Container -> Internal LB)
resource "aws_security_group_rule" "sbcntr-sg-internal-from-sg-management-tcp-test-port" {
  type      = "ingress"
  from_port = 10080
  to_port   = 10080
  protocol  = "tcp"
  # Managementからのアクセスを許可する
  source_security_group_id = aws_security_group.sbcntr-sg-management.id
  security_group_id        = aws_security_group.sbcntr-sg-internal.id
  description              = "Test port for management server"
}

# DB用セキュリティグループ
resource "aws_security_group" "sbcntr-sg-db" {
  name        = "sbcntr-sg-db"
  vpc_id      = aws_vpc.sbcntr-vpc.id
  description = "security group of database"

  tags = {
    Name : "sbcntr-sg-db"
  }

  # Backend container -> DB
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    description     = "MySQL protocol from backend app"
    security_groups = [aws_security_group.sbcntr-sg-container.id]
  }
  # Frontend container -> DB
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    description     = "MySQL protocol from frontend app"
    security_groups = [aws_security_group.sbcntr-sg-front-container.id]
  }
  # Management container -> DB
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    description     = "MySQL protocol from management server"
    security_groups = [aws_security_group.sbcntr-sg-management.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "allow all outbound traffic by default"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# VPCエンドポイント用のセキュリティグループ
resource "aws_security_group" "sbcntr-sg-egress" {
  name        = "sbcntr-sg-egress"
  vpc_id      = aws_vpc.sbcntr-vpc.id
  description = "security group of vpc endpoint"

  tags = {
    Name : "sbcntr-sg-egress"
  }

  ### Back container -> VPC endpoint
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    description     = "HTTPS for backend app"
    security_groups = [aws_security_group.sbcntr-sg-container.id]
  }

  ### Front container -> VPC endpoint
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    description     = "HTTPS for frontend app"
    security_groups = [aws_security_group.sbcntr-sg-front-container.id]
  }

  ### Management Server -> VPC endpoint
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    description     = "HTTPS for management server"
    security_groups = [aws_security_group.sbcntr-sg-management.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "allow all outbound traffic by default"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
