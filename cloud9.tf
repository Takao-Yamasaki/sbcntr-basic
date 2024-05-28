# # 開発環境 Cloud9
# # NOTE: 作業中のためコメントアウト 
# resource "aws_cloud9_environment_ec2" "sbcntr-dev" {
#   instance_type               = "t2.micro"
#   name                        = "sbcntr-dev"
#   image_id                    = "amazonlinux-2023-x86_64"
#   description                 = "cloud9 for application development"
#   automatic_stop_time_minutes = 60            // インスタンスが終了するまでの分数
#   connection_type             = "CONNECT_SSM" // SSM接続
#   subnet_id                   = aws_subnet.sbcntr-subnet-public-management-1a.id
# }

# output "cloud9_environment_id" {
#   value = aws_cloud9_environment_ec2.sbcntr-dev.id
# }
