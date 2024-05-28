# ロググループ(Backend)
# https://dev.classmethod.jp/articles/output-each-containers-logs-in-same-task-by-terraform/
resource "aws_cloudwatch_log_group" "sbcntr-cloudwatch-logs-backend" {
  name = "/ecs/sbcntr-backend-def"
  # ロググループを削除しない
  skip_destroy = true
  # ログイベントの保持日数を指定
  retention_in_days = 14
}

# ロググループ(Frontend)
resource "aws_cloudwatch_log_group" "sbcntr-cloudwatch-logs-frontend" {
  name = "/ecs/sbcntr-frontend-def"
  # ロググループを削除しない
  skip_destroy = true
  # ログイベントの保持日数を指定
  retention_in_days = 14
}
