# インターネット公開用セキュリティグループ
resource "aws_security_group" "sbcntr-sg-ingress" {
  name = "sbcntr-sg-ingress"
  vpc_id = aws_vpc.sbcntrVPC.id
  description = "security group for ingress"
  tags = {
    Name: "sbcntr-sg-ingress" 
  }

  # -> IGW
  ingress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    description = "allow all outbound traffic by default"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

# 管理用サーバー向けのセキュリティグループ
resource "aws_security_group" "sbcntr-sg-management" {
  name = "sbcntr-sg-management"
  vpc_id = aws_vpc.sbcntrVPC.id
  description = "security group for management server"
  
  tags = {
    Name: "sbcntr-sg-management"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    description = "allow all outbound traffic by default"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

# バックエンドコンテナアプリ用のセキュリティグループ
resource "aws_security_group" "sbcntr-sg-container" {
  name = "sbcntr-sg-container"
  vpc_id = aws_vpc.sbcntrVPC.id
  description = "security group of backend app"

  tags = {
    Name: "sbcntr-sg-container"
  }

# Internal LB -> Backend Container
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    description = "HTTP for internal lb"
    security_groups = [ aws_security_group.sbcntr-sg-internal.id ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    description = "allow all outbound traffic by default"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

# フロントエンドコンテナアプリ用のセキュリティグループ
resource "aws_security_group" "sbcntr-sg-front-container" {
  name = "sbcntr-sg-front-container"
  vpc_id = aws_vpc.sbcntrVPC.id
  description = "security group of front container app"

  tags = {
    Name: "sbcntr-sg-front-container"
  }

  # Internet LB -> Frontend Container
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    description =  "HTTP for Ingress"
    security_groups = [ aws_security_group.sbcntr-sg-ingress.id ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    description = "allow all outbound traffic by default"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

# 内部用ロードバランサー用のセキュリティグループ
resource "aws_security_group" "sbcntr-sg-internal" {
  name = "sbcntr-sg-internal"
  vpc_id = aws_vpc.sbcntrVPC.id
  description = "security group for internal load balancer"
  tags = {
    Name: "sbcntr-sg-internal"
  }

  # Frontend Container -> Internal LB
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    description = "HTTP for frontend container"
    security_groups = [ aws_security_group.sbcntr-sg-front-container.id ]
  }
  # Management Container -> Internal LB 
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    description = "HTTP for management server"
    security_groups = [ aws_security_group.sbcntr-sg-management.id ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    description = "allow all outbound traffic by default"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

# DB用セキュリティグループ
resource "aws_security_group" "sbcntr-sg-db" {
  name = "sbcntr-sg-db"
  vpc_id = aws_vpc.sbcntrVPC.id
  description = "security group of database"

  tags = {
    Name: "sbcntr-sg-internal"
  }

  # Backend container -> DB
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    description = "MySQL protocol from backend app"
    security_groups = [ aws_security_group.sbcntr-sg-container.id ]
  }
  # Frontend container -> DB
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    description = "MySQL protocol from frontend app"
    security_groups = [ aws_security_group.sbcntr-sg-front-container.id ]
  }
  # Management container -> DB
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    description = "MySQL protocol from management server"
    security_groups = [ aws_security_group.sbcntr-sg-management.id ]
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    description = "allow all outbound traffic by default"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}
