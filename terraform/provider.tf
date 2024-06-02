// 環境情報を定義
variable "aws_region" {}

// 必要なプロバイダとそのバージョンを定義
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws" // AWSプロバイダのソース
      version = "~> 5.38"       // バージョン指定
    }
  }
}

// AWSプロバイダの設定
provider "aws" {
  region = var.aws_region
}

# アカウントIDを取得
data "aws_caller_identity" "self" {}
