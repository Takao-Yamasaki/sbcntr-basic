# terraform import
## https://tech.layerx.co.jp/entry/improve-iac-development-with-terraform-import

# プライベートリポジトリ バックエンド
## https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository.html
resource "aws_ecr_repository" "sbcntr-backend" {
  name                 = "sbcntr-backend"

  # タグの重複を許可しない
  image_tag_mutability = "IMMUTABLE"

  # 脆弱性スキャンの有効化
  image_scanning_configuration {
    scan_on_push = true
  }
}

# ライフサイクルポリシー バックエンド
## https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy
resource "aws_ecr_lifecycle_policy" "sbcntr-backend" {
  repository = aws_ecr_repository.sbcntr-backend.name
  policy = <<-EOT
  {
    "roles": [
      {
        "rolePriority": 1,
        "description": "古い世代のイメージを削除",
        "selection": {
          "countUint": "imageCountMoreThan",
          "countNumber": 30
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
  EOT
}

# プライベートリポジトリ フロントエンド
resource "aws_ecr_repository" "sbcntr-frontend" {
  name                 = "sbcntr-frontend"

  # タグの重複を許可しない
  image_tag_mutability = "IMMUTABLE"

  # 脆弱性スキャンの有効化
  image_scanning_configuration {
    scan_on_push = true
  }
}

# ライフサイクルポリシー フロントエンド
## https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy
resource "aws_ecr_lifecycle_policy" "sbcntr-frontend" {
  repository = aws_ecr_repository.sbcntr-frontend.name
  policy = <<-EOT
  {
    "roles": [
      {
        "rolePriority": 1,
        "description": "古い世代のイメージを削除",
        "selection": {
          "countUint": "imageCountMoreThan",
          "countNumber": 30
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
  EOT
}

# プライベートリポジトリ(共通のベースイメージ)
resource "aws_ecr_repository" "sbcntr-base" {
  name                 = "sbcntr-base"
  
  # タグの重複を許可しない
  image_tag_mutability = "IMMUTABLE"

  # 脆弱性スキャンの有効化
  image_scanning_configuration {
    scan_on_push = true
  }
}

# ライフサイクルポリシー 共通のベースイメージ
## https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy
resource "aws_ecr_lifecycle_policy" "sbcntr-base" {
  repository = aws_ecr_repository.sbcntr-base.name
  policy = <<-EOT
  {
    "roles": [
      {
        "rolePriority": 1,
        "description": "古い世代のイメージを削除",
        "selection": {
          "countUint": "imageCountMoreThan",
          "countNumber": 30
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
  EOT
}
