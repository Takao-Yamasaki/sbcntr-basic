# NOTE: 作業中のためコメントアウト
# resource "aws_vpc" "sbcntr-vpc" {
#   cidr_block           = "10.0.0.0/16"
#   enable_dns_support   = true
#   enable_dns_hostnames = true

#   tags = {
#     Name = "sbctr-vpc"
#   }
# }

# Ingress用パブリックサブネット
resource "aws_subnet" "sbcntr-subnet-public-ingress-1a" {
  vpc_id                  = aws_vpc.sbcntr-vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1a"
  tags = {
    "Name" : "sbcntr-subnet-public-ingress-1a",
    "Type" : "public",
  }
}

# Ingress用パブリックサブネット
resource "aws_subnet" "sbcntr-subnet-public-ingress-1c" {
  vpc_id                  = aws_vpc.sbcntr-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1c"
  tags = {
    "Name" : "sbcntr-subnet-public-ingress-1c",
    "Type" : "public",
  }
}

# Ingress用ルートテーブル
resource "aws_route_table" "sbcntr-route-ingress" {
  vpc_id = aws_vpc.sbcntr-vpc.id
  tags = {
    "Name" = "sbcntr-route-ingress"
  }
}

# Ingress用パブリックサブネットへの紐付け
resource "aws_route_table_association" "sbcntr-route-ingress-association-1c" {
  route_table_id = aws_route_table.sbcntr-route-ingress.id
  subnet_id      = aws_subnet.sbcntr-subnet-public-ingress-1c.id
}

# Ingress用パブリックサブネットへの紐付け
resource "aws_route_table_association" "sbcntr-route-ingress-association-1a" {
  route_table_id = aws_route_table.sbcntr-route-ingress.id
  subnet_id      = aws_subnet.sbcntr-subnet-public-ingress-1a.id
}


# コンテナアプリ用プライベートサブネット
resource "aws_subnet" "sbcntr-subnet-private-container-1a" {
  vpc_id                  = aws_vpc.sbcntr-vpc.id
  cidr_block              = "10.0.8.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "ap-northeast-1a"
  tags = {
    "Name" : "sbcntr-subnet-private-container-1a",
    "Type" : "isolated",
  }
}

# コンテナアプリ用プライベートサブネット
resource "aws_subnet" "sbcntr-subnet-private-container-1c" {
  vpc_id                  = aws_vpc.sbcntr-vpc.id
  cidr_block              = "10.0.9.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "ap-northeast-1c"
  tags = {
    "Name" : "sbcntr-subnet-private-container-1c",
    "Type" : "isolated",
  }
}

# コンテナアプリ用ルートテーブル
resource "aws_route_table" "sbcntr-route-app" {
  vpc_id = aws_vpc.sbcntr-vpc.id
  tags = {
    "Name" = "sbcntr-route-app"
  }
}

# コンテナサブネットへの紐付け
resource "aws_route_table_association" "sbcntr-route-app-association-1a" {
  route_table_id = aws_route_table.sbcntr-route-app.id
  subnet_id      = aws_subnet.sbcntr-subnet-private-container-1a.id
}

# コンテナサブネットへの紐付け
resource "aws_route_table_association" "sbcntr-route-app-association-1c" {
  route_table_id = aws_route_table.sbcntr-route-app.id
  subnet_id      = aws_subnet.sbcntr-subnet-private-container-1c.id
}

# DB用プライベートサブネット
resource "aws_subnet" "sbcntr-subnet-private-db-1a" {
  vpc_id                  = aws_vpc.sbcntr-vpc.id
  cidr_block              = "10.0.16.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "ap-northeast-1a"
  tags = {
    "Name" : "sbcntr-subnet-private-db-1a",
    "Type" : "isolated",
  }
}

# DB用プライベートサブネット
resource "aws_subnet" "sbcntr-subnet-private-db-1c" {
  vpc_id                  = aws_vpc.sbcntr-vpc.id
  cidr_block              = "10.0.17.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "ap-northeast-1c"
  tags = {
    "Name" : "sbcntr-subnet-private-db-1c",
    "Type" : "isolated",
  }
}

# DB用のルートテーブル
resource "aws_route_table" "sbcntr-route-db" {
  vpc_id = aws_vpc.sbcntr-vpc.id
  tags = {
    "Name" = "sbcntr-route-db"
  }
}

# DBサブネットへの紐付け
resource "aws_route_table_association" "sbcntr-route-db-association-1a" {
  route_table_id = aws_route_table.sbcntr-route-db.id
  subnet_id      = aws_subnet.sbcntr-subnet-private-db-1a.id
}

# DBサブネットへの紐付け
resource "aws_route_table_association" "sbcntr-route-db-association-1c" {
  route_table_id = aws_route_table.sbcntr-route-db.id
  subnet_id      = aws_subnet.sbcntr-subnet-private-db-1c.id
}

# # 管理用のパブリックサブネット
# resource "aws_subnet" "sbcntr-subnet-public-management-1a" {
#   vpc_id                  = aws_vpc.sbcntr-vpc.id
#   cidr_block              = "10.0.240.0/24"
#   map_public_ip_on_launch = true
#   availability_zone       = "ap-northeast-1a"
#   tags = {
#     "Name" : "sbcntr-subnet-public-management-1a",
#     "Type" : "public",
#   }
# }

# 管理用のパブリックサブネット
resource "aws_subnet" "sbcntr-subnet-public-management-1c" {
  vpc_id                  = aws_vpc.sbcntr-vpc.id
  cidr_block              = "10.0.241.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1c"
  tags = {
    "Name" : "sbcntr-subnet-public-management-1c",
    "Type" : "public",
  }
}

# 管理用サブネットのルートはIngressと同様
resource "aws_route_table_association" "sbcntr-subnet-management-association-1a" {
  route_table_id = aws_route_table.sbcntr-route-ingress.id
  subnet_id      = aws_subnet.sbcntr-subnet-public-management-1a.id
}

# 管理用サブネットのルートはIngressと同様
resource "aws_route_table_association" "sbcntr-subnet-management-association-1c" {
  route_table_id = aws_route_table.sbcntr-route-ingress.id
  subnet_id      = aws_subnet.sbcntr-subnet-public-management-1c.id
}

# VPCエンドポイント（Egress）用のプライベートサブネット
resource "aws_subnet" "sbcntr-subnet-private-egress-1a" {
  vpc_id                  = aws_vpc.sbcntr-vpc.id
  cidr_block              = "10.0.248.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "ap-northeast-1a"
  tags = {
    "Name" : "sbcntr-subnet-private-egress-1a",
    "Type" : "isolated",
  }
}
# VPCエンドポイント（Egress）用のプライベートサブネット
resource "aws_subnet" "sbcntr-subnet-private-egress-1c" {
  vpc_id                  = aws_vpc.sbcntr-vpc.id
  cidr_block              = "10.0.249.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "ap-northeast-1c"

  tags = {
    "Name" : "sbcntr-subnet-private-egress-1c",
    "Type" : "isolated",
  }
}


# # IGW
# resource "aws_internet_gateway" "sbcntr-igw" {
#   vpc_id = aws_vpc.sbcntr-vpc.id
# }

# ルート
resource "aws_route" "sbcntr-route-ingress-default" {
  route_table_id         = aws_route_table.sbcntr-route-ingress.id
  gateway_id             = aws_internet_gateway.sbcntr-igw.id
  destination_cidr_block = "0.0.0.0/0"
}
