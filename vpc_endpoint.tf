# VPCエンドポイント（インターフェース型）
resource "aws_vpc_endpoint" "sbcntr-vpce-ecr-api" {
  vpc_id = aws_vpc.sbcntrVPC.id
  service_name      = "com.amazonaws.ap-northeast-1.ecr.api"
  vpc_endpoint_type = "Interface"
  subnet_ids = [ 
    aws_subnet.sbcntr-subnet-private-egress-1a.id,
    aws_subnet.sbcntr-subnet-private-egress-1c.id,
  ]

  # セキュリティグループをアタッチ
  security_group_ids = [ aws_security_group.sbcntr-sg-egress.id]

  # プライベートDNS名を有効
  private_dns_enabled = true
  
  # フルアクセスを指定
  policy = <<EOT
  {
    "Statement": [
        {
            "Action": "*",
            "Effect": "Allow",
            "Principal": "*",
            "Resource": "*"
        }
    ]
  }
  EOT

  tags = {
    Name: "sbcntr-vpce-ecr-api"
  }
}

# VPCエンドポイント（インターフェース型）
resource "aws_vpc_endpoint" "sbcntr-vpce-ecr-dkr" {
  vpc_id = aws_vpc.sbcntrVPC.id
  service_name      = "com.amazonaws.ap-northeast-1.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids = [ 
    aws_subnet.sbcntr-subnet-private-egress-1a.id,
    aws_subnet.sbcntr-subnet-private-egress-1c.id,
  ]

  # セキュリティグループをアタッチ
  security_group_ids = [ aws_security_group.sbcntr-sg-egress.id]

  # プライベートDNS名を有効
  private_dns_enabled = true
  
  # フルアクセスを指定
  policy = <<EOT
  {
    "Statement": [
        {
            "Action": "*",
            "Effect": "Allow",
            "Principal": "*",
            "Resource": "*"
        }
    ]
  }
  EOT

  tags = {
    Name: "sbcntr-vpce-ecr-dkr"
  }
}

# # VPCエンドポイント（ゲートウェイ型）
# resource "aws_vpc_endpoint" "sbcntr-vpce-s3" {
#   vpc_id = aws_vpc.sbcntrVPC.id
#   service_name      = "com.amazonaws.ap-northeast-1.s3"
#   vpc_endpoint_type = "Gateway"

#   route_table_ids = [ aws_route_table.sbcntr-public-route-table.id ]
  
#   # フルアクセスを指定
#   policy = <<EOT
#   {
#     "Statement": [
#         {
#             "Action": "*",
#             "Effect": "Allow",
#             "Principal": "*",
#             "Resource": "*"
#         }
#     ]
#   }
#   EOT

#   tags = {
#     Name: "sbcntr-vpce-s3"
#   }
# }
