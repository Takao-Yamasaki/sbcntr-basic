# ビルドプロジェクトの作成
resource "aws_codebuild_project" "sbcntr-codebuild" {
  name          = "sbcntr-codebuild"
  badge_enabled = true

  source {
    type     = "CODECOMMIT"
    location = aws_codecommit_repository.sbcntr-backend.clone_url_http

  }

  # ソースバージョン
  source_version = "refs/heads/main"

  # キュータイムアウト: 1時間
  build_timeout = 60
  # キュータイムアウト: 8時間
  queued_timeout = 480


  # NOTE: ビルド定義のなかで、ECRへプッシュするため、アーティファクトなし
  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    # キャッシュタイプ
    # NOTE: ビルドの高速化のため
    type = "LOCAL"
    # DockerLayerCacheを設定
    # NOTE: Dockerビルドの時間短縮のため
    modes = ["LOCAL_DOCKER_LAYER_CACHE"]
  }
  service_role = aws_iam_role.sbcntr-codebuild-role.arn

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    # 特権付与
    privileged_mode = true
  }

  # Cloud Watchのログを有効化
  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

}
