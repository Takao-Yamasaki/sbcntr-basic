# VPCエンドポイント（インターフェース型）
# ECR APIの呼び出しに使用する
resource "aws_vpc_endpoint" "sbcntr-vpce-ecr-api" {
  vpc_id            = aws_vpc.sbcntr-vpc.id
  service_name      = "com.amazonaws.ap-northeast-1.ecr.api"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.sbcntr-subnet-private-egress-1a.id,
    aws_subnet.sbcntr-subnet-private-egress-1c.id,
  ]

  # セキュリティグループをアタッチ
  security_group_ids = [aws_security_group.sbcntr-sg-egress.id]

  # プライベートDNS名を有効
  private_dns_enabled = true

  tags = {
    Name : "sbcntr-vpce-ecr-api"
  }
}

# VPCエンドポイント（インターフェース型）
# Dockerクライアントの呼び出しに使用する
resource "aws_vpc_endpoint" "sbcntr-vpce-ecr-dkr" {
  vpc_id            = aws_vpc.sbcntr-vpc.id
  service_name      = "com.amazonaws.ap-northeast-1.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.sbcntr-subnet-private-egress-1a.id,
    aws_subnet.sbcntr-subnet-private-egress-1c.id,
  ]

  # セキュリティグループをアタッチ
  security_group_ids = [aws_security_group.sbcntr-sg-egress.id]

  # プライベートDNS名を有効
  private_dns_enabled = true

  tags = {
    Name : "sbcntr-vpce-ecr-dkr"
  }
}
# VPCエンドポイント（インターフェース型）
# ColudWatch logs(Fargateのログ転送経路)に使用する
resource "aws_vpc_endpoint" "sbcntr-vpce-logs" {
  vpc_id            = aws_vpc.sbcntr-vpc.id
  service_name      = "com.amazonaws.ap-northeast-1.logs"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.sbcntr-subnet-private-egress-1a.id,
    aws_subnet.sbcntr-subnet-private-egress-1c.id,
  ]

  # セキュリティグループをアタッチ
  security_group_ids = [aws_security_group.sbcntr-sg-egress.id]

  # プライベートDNS名を有効
  private_dns_enabled = true

  tags = {
    Name : "sbcntr-vpce-logs"
  }
}

# VPCエンドポイント（ゲートウェイ型）
# S3のイメージ取得に使用する
resource "aws_vpc_endpoint" "sbcntr-vpce-s3" {
  vpc_id            = aws_vpc.sbcntr-vpc.id
  service_name      = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.sbcntr-route-app.id
  ]

  tags = {
    Name : "sbcntr-vpce-s3"
  }
}

# VPCエンドポイント（インターフェース型）
# ECSタスクエージェントがSecrets Managerへ到達するのに使用
resource "aws_vpc_endpoint" "sbcntr-vpce-secrets" {
  vpc_id            = aws_vpc.sbcntr-vpc.id
  service_name      = "com.amazonaws.ap-northeast-1.secretsmanager"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.sbcntr-subnet-private-egress-1a.id,
    aws_subnet.sbcntr-subnet-private-egress-1c.id,
  ]

  # セキュリティグループをアタッチ
  security_group_ids = [aws_security_group.sbcntr-sg-egress.id]

  # プライベートDNS名を有効
  private_dns_enabled = true

  tags = {
    Name : "sbcntr-vpce-secrets"
  }
}
