resource "aws_vpc" "sbcntrVPC" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "sbctrVPC"
  }
}

# Ingress用
resource "aws_subnet" "sbcntr-subnet-public-ingress-1a" {
  vpc_id = aws_vpc.sbcntrVPC.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1a"
}

# Ingress用
resource "aws_subnet" "sbcntr-subnet-public-ingress-1c" {
  vpc_id = aws_vpc.sbcntrVPC.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1c"
}

# アプリケーション用
resource "aws_subnet" "sbcntr-subnet-private-container-1a" {
  vpc_id = aws_vpc.sbcntrVPC.id
  cidr_block = "10.0.8.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1a"
}

# アプリケーション用
resource "aws_subnet" "sbcntr-subnet-private-container-1c" {
  vpc_id = aws_vpc.sbcntrVPC.id
  cidr_block = "10.0.9.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1c"
}

# DB用
resource "aws_subnet" "sbcntr-subnet-private-db-1a" {
  vpc_id = aws_vpc.sbcntrVPC.id
  cidr_block = "10.0.16.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1c"
}

# DB用
resource "aws_subnet" "sbcntr-subnet-private-db-1c" {
  vpc_id = aws_vpc.sbcntrVPC.id
  cidr_block = "10.0.17.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1c"
}

# 管理用
resource "aws_subnet" "sbcntr-subnet-public-management-1a" {
  vpc_id = aws_vpc.sbcntrVPC.id
  cidr_block = "10.0.240.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1a"
}

# 管理用
resource "aws_subnet" "sbcntr-subnet-public-management-1c" {
  vpc_id = aws_vpc.sbcntrVPC.id
  cidr_block = "10.0.241.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1c"
}

# Egress用
resource "aws_subnet" "sbcntr-subnet-private-egress-1a" {
  vpc_id = aws_vpc.sbcntrVPC.id
  cidr_block = "10.0.248.0/24"
  availability_zone = "ap-northeast-1a"
}
# Egress用
resource "aws_subnet" "sbcntr-subnet-private-egress-1c" {
  vpc_id = aws_vpc.sbcntrVPC.id
  cidr_block = "10.0.249.0/24"
  availability_zone = "ap-northeast-1c"
}


# IGW
resource "aws_internet_gateway" "sbcntr-igw" {
  vpc_id = aws_vpc.sbcntrVPC.id
}

# ルートテーブル(共通)
resource "aws_route_table" "sbcntr-public-route-table" {
  vpc_id = aws_vpc.sbcntrVPC.id
}

# ルート
resource "aws_route" "sbcntr-public-route" {
  route_table_id = aws_route_table.sbcntr-public-route-table.id
  gateway_id = aws_internet_gateway.sbcntr-igw.id
  destination_cidr_block = "0.0.0.0/0"
}

# ルートテーブルの関連付け
resource "aws_route_table_association" "sbcntr-subnet-public-ingress-1a" {
  subnet_id = aws_subnet.sbcntr-subnet-public-ingress-1a.id
  route_table_id = aws_route_table.sbcntr-public-route-table.id
}

# ルートテーブルの関連付け
resource "aws_route_table_association" "sbcntr-subnet-public-ingress-1c" {
  subnet_id = aws_subnet.sbcntr-subnet-public-ingress-1c.id
  route_table_id = aws_route_table.sbcntr-public-route-table.id
}

# ルートテーブルの関連付け
resource "aws_route_table_association" "sbcntr-subnet-public-management-1a" {
  subnet_id = aws_subnet.sbcntr-subnet-public-management-1a.id
  route_table_id = aws_route_table.sbcntr-public-route-table.id
}

# ルートテーブルの関連付け
resource "aws_route_table_association" "sbcntr-subnet-public-management-1c" {
  subnet_id = aws_subnet.sbcntr-subnet-public-management-1c.id
  route_table_id = aws_route_table.sbcntr-public-route-table.id
}

# TODO: ルートテーブル周り変更すること
