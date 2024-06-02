# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline
resource "aws_codepipeline" "sbcntr-pipeline" {
  name     = "sbcntr-pipeline"
  role_arn = aws_iam_role.sbcntr-codepipeline-role.arn
  artifact_store {
    location = aws_s3_bucket.sbcntr-codepipeline-bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["SourceArtifact"]
      namespace        = "SourceVariables"

      configuration = {
        RepositoryName       = aws_codecommit_repository.sbcntr-backend.repository_name
        BranchName           = "main"
        PollforSourceChanges = "false"
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }
  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      provider         = "CodeBuild"
      version          = "1"
      owner            = "AWS"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]

      configuration = {
        ProjectName = aws_codebuild_project.sbcntr-codebuild.name
      }
    }
  }
  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      version         = "1"
      input_artifacts = ["BuildArtifact", "SourceArtifact"]
      configuration = {
        ApplicationName        = "sbcntr-backend"
        DeploymentGroupName    = "sbcntr-ecs-backend-deployment-group"
        TaskDefinitionArtifact = "SourceArtifact",
        AppSecTemplateArtifact = "SourceArtifact",
        Image1ArtifactName     = "BuildArtifact",
        Image1ContainerName    = "IMAGE1_NAME"
      }
    }
  }
}

# S3バケットの作成
resource "aws_s3_bucket" "sbcntr-codepipeline-bucket" {
  bucket = "sbcntr-codepipeline-bucket"
}

# プライベートS3バケットの設定
resource "aws_s3_bucket_acl" "sbcntr-codepipeline-bucket" {
  bucket = aws_s3_bucket.sbcntr-codepipeline-bucket.bucket
  acl    = "private"
}

# S3バケットのサーバーサイド暗号化設定
resource "aws_s3_bucket_server_side_encryption_configuration" "sbcntr-codepipeline-bucket" {
  bucket = aws_s3_bucket.sbcntr-codepipeline-bucket.bucket

  rule {
    bucket_key_enabled = false

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# CloudWatch イベントルール
resource "aws_cloudwatch_event_rule" "sbcntr-codepipeline-push-repository" {
  name        = "sbcntr-codepipeline-push-repository"
  description = "sbcntr-codepipeline-push-repository"

  event_pattern = <<-EOF
  {
    "source": ["aws_codecommit"],
    "detail-type": ["CodeCommit Repository Stage Change"],
    "resources": ["${aws_codecommit_repository.sbcntr-backend.arn}"],
    "datail": {
      "event": ["referenceCreated", "referenceUpdated"],
      "referenceTyped": ["branch"],
      "referenceName": ["main"]
    }
  }
  EOF
}

resource "aws_cloudwatch_event_target" "sbcntr-codepipeline-push-repository" {
  rule     = aws_cloudwatch_event_rule.sbcntr-codepipeline-push-repository.name
  arn      = aws_codepipeline.sbcntr-pipeline.arn
  role_arn = aws_iam_role.sbcntr-codepipeline-cloudwatch-event-role.arn
}
