// Secrets Managerの設定
// シークレットの作成
resource "aws_secretsmanager_secret" "sbcntr-mysql-secret" {
  name = "sbcntr/mysql"
  description = "コンテナユーザー用sbcntr-dbアクセスのシークレット"

  tags = {
    Name = "sbcntr-mysql"
  }
}
// シークレット値をkey:valueで登録
resource "aws_secretsmanager_secret_version" "sbcntr-mysql-secret-version" {
  secret_id = aws_secretsmanager_secret.name.id
  secret_string = jsonencode(local.sbcntrMySqlSecretString)
}

locals {
  sbcntrMySqlSecretString = {
    engine = "mysql"
    host = aws_rds_cluster.sbcntr-db-cluster.endpoint
    username = "sbcntruser"
    password = "sbcntrEncP"
    dbname = "sbcntrapp"
  }
}
