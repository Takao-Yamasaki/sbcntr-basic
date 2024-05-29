# DBサブネットグループの作成
## https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group
resource "aws_db_subnet_group" "sbcntr-rds-subnet-group" {
  name        = "sbcntr-rds-subnet-group"
  subnet_ids  = [aws_subnet.sbcntr-subnet-private-db-1a, aws_subnet.sbcntr-subnet-private-container-1c]
  description = "DB subnet group for Aurora"

  tags = {
    Name = "sbcntr-rds-subnet-group"
  }
}

# パラメータグループ
resource "aws_db_parameter_group" "sbcntr-aurora-rds-parameter-group" {
  name   = "sbcntr-aurora-rds-parameter-group"
  family = "aurora-mysql5.7"

  tags = {
    Name = "sbcntr-aurora-rds-parameter-group"
  }
}

# クラスターパラメータグループ
resource "aws_rds_cluster_parameter_group" "sbcntr-aurora-rds-cluster-parameter-group" {
  name   = "sbcntr-aurora-rds-cluster-parameter-group"
  family = "aurora-mysql5.7"

  tags = {
    Name = "sbcntr-aurora-rds-cluster-parameter-group"
  }
}

# DBクラスターの作成
## https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster
resource "aws_rds_cluster" "sbcntr-db-cluster" {
  cluster_identifier = "sbcntr-db"
  engine             = "aurora-mysql"
  engine_version     = "5.7.mysql_aurora.2.10.2"
  master_username    = "admin"
  # パスワードはAWS側で自動生成
  master_password                  = random_password.sbcntr-db-password.result
  db_subnet_group_name             = aws_db_subnet_group.sbcntr-rds-subnet-group.name
  vpc_security_group_ids           = [aws_security_group.sbcntr-sg-db.id]
  port                             = 3306
  database_name                    = "sbcntrapp"
  db_cluster_parameter_group_name  = aws_rds_cluster_parameter_group.sbcntr-aurora-rds-cluster-parameter-group.name
  db_instance_parameter_group_name = aws_db_parameter_group.sbcntr-aurora-rds-parameter-group.name
  # バックアップの保持期間は1日
  backup_retention_period = 1
  preferred_backup_window = "05:00-07:00"
  # スナップショットにタグをコピー
  copy_tags_to_snapshot = true
  # 監査ログ・エラーログ・スロークエリログをエクスポート
  enabled_cloudwatch_logs_exports = ["audit", "error", "slowquery"]
  # 暗号を有効化
  storage_encrypted = true
  # 削除保護の有効化
  deletion_protection = true
  skip_final_snapshot = true

  tags = {
    Name = "sbcntr-db"
  }

  lifecycle {
    ignore_changes = [
      master_password
    ]
  }
}

# Auroraインスタンスの作成
resource "aws_rds_cluster_instance" "name" {
  count              = 2
  identifier         = "sbcntr-db-${count.index}"
  cluster_identifier = aws_rds_cluster.sbcntr-db-cluster.id
  # DBインスタンスサイズ
  instance_class = "db.t3.small"
  engine         = aws_rds_cluster.sbcntr-db-cluster.engine
  engine_version = aws_rds_cluster.sbcntr-db-cluster.engine_version
  # パブリックアクセスは無効
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.sbcntr-rds-subnet-group.name
  # モニタリングで1分間隔でログを取得
  monitoring_interval        = 60
  monitoring_role_arn        = aws_iam_role.rds-monitering-role.arn
  auto_minor_version_upgrade = true
  # メンテナンスの開始日
  # NOTE: UTCなので、日曜の深夜2時から
  preferred_backup_window = "Sat:17:00-Sat:17:30"

  tags = {
    Name = "sbcntr-db-${count.index}"
  }
}

// パスワートを自動生成
// https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password
resource "random_password" "sbcntr-db-password" {
  length = 16
  // 特殊文字を含める
  special = true
  // 文字列生成に使用する特殊文字列のリスト
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
