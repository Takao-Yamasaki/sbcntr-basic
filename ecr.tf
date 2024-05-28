# # プライベートリポジトリ バックエンド
# # NOTE: 作業中のためコメントアウト 
# resource "aws_ecr_repository" "sbcntr-backend" {
#   name                 = "sbcntr-backend"
#   image_tag_mutability = "MUTABLE"

#   image_scanning_configuration {
#     scan_on_push = false
#   }
# }

# # プライベートリポジトリ フロントエンド
# # NOTE: 作業中のためコメントアウト
# resource "aws_ecr_repository" "sbcntr-frontend" {
#   name                 = "sbcntr-frontend"
#   image_tag_mutability = "MUTABLE"

#   image_scanning_configuration {
#     scan_on_push = false
#   }
# }
