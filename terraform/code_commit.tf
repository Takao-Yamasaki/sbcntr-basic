# CodeCommit Repositoryの作成
## https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codecommit_repository
resource "aws_codecommit_repository" "sbcntr-backend" {
  repository_name = "sbcntr-backend"
  description     = "Repository for sbcntr backend application"
}

# CodeCommitのURLを出力
output "codecommit-repository-url" {
  value = aws_codecommit_repository.sbcntr-backend.clone_url_http
}
