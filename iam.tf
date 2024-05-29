# IAMポリシーの作成
resource "aws_iam_policy" "sbcntr-accessing-ecr-repository-policy" {
  name        = "sbcntr-accessing-ecr-repository-policy"
  description = "policy to access ecr repo from cloud9 instance"
  policy      = <<-EOT
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "ecr:ListImages",
            "Resource": [
                "arn:aws:ecr:ap-northeast-1:${data.aws_caller_identity.self.account_id}:repository/sbcntr-backend",
                "arn:aws:ecr:ap-northeast-1:${data.aws_caller_identity.self.account_id}:repository/sbcntr-frontend"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "ecr:GetAuthorizationToken",
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:CompleteLayerUpload",
                "ecr:DescribeImages",
                "ecr:DescribeRepositories",
                "ecr:UploadLayerPart",
                "ecr:ListImages",
                "ecr:InitiateLayerUpload",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetRepositoryPolicy",
                "ecr:PutImage"
            ],
            "Resource": [
                "arn:aws:ecr:ap-northeast-1:${data.aws_caller_identity.self.account_id}:repository/sbcntr-backend",
                "arn:aws:ecr:ap-northeast-1:${data.aws_caller_identity.self.account_id}:repository/sbcntr-frontend"
            ]
        }
    ]
  }
  EOT
}

# IAMロールの作成
resource "aws_iam_role" "sbcntr-cloud9-role" {
  name        = "sbcntr-cloud9-role"
  description = "allow ec2 instance to call aws services on your behalf."
  // 信頼関係の設定
  assume_role_policy = <<-EOT
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
            "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOT

}

# 作成したIAMポリシーのアタッチ
resource "aws_iam_role_policy_attachment" "sbcntr-cloud9-role" {
  role       = aws_iam_role.sbcntr-cloud9-role.name
  policy_arn = aws_iam_policy.sbcntr-accessing-ecr-repository-policy.arn
}

# 既存のIAMポリシーのアタッチ(SSM用)
resource "aws_iam_role_policy_attachment" "sbcntr-cloud9-ssm-instance-profile" {
  role       = aws_iam_role.sbcntr-cloud9-role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCloud9SSMInstanceProfile"
}

# 既存のIAMポリシーのアタッチ(EC2用)
resource "aws_iam_role_policy_attachment" "sbcntr-cloud9-ec2-container-registory" {
  role       = aws_iam_role.sbcntr-cloud9-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

# 既存のIAMポリシーのアタッチ(EBS用)
# NOTE: ec2:DescribeVolumesModificationsを追加するため
resource "aws_iam_role_policy_attachment" "sbcntr-cloud9-ec2-full-access" {
  role       = aws_iam_role.sbcntr-cloud9-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# IAMインスタンスプロファイルの定義
resource "aws_iam_instance_profile" "sbcntr-cloud9-role" {
  name = "sbcntr-cloud9-role"
  role = aws_iam_role.sbcntr-cloud9-role.name
}

# IAMロールの作成(Blue/Green)
resource "aws_iam_role" "ecs-codedeploy-role" {
  name        = "ecs-codedeploy-role"
  description = "Allow CodeDeploy to read S3 objects, invoke Lamda functions, publish to SNS topics, and update ECS services on your behalf."
  // 信頼関係の設定
  assume_role_policy = <<-EOT
  {
  "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "codedeploy.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOT

}

# IAMポリシーのアタッチ(Blue/Green)
resource "aws_iam_role_policy_attachment" "ecs-codedeploy-role" {
  role       = aws_iam_role.ecs-codedeploy-role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

# IAMロールの作成（for ECS）
resource "aws_iam_role" "ecs-task-execution-role" {
  name               = "ecs-task-execution-role"
  assume_role_policy = <<-EOT
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOT
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role" {
  role       = aws_iam_role.ecs-task-execution-role.name
  policy_arn = aws_iam_policy.ecs_task_execution_policy.arn
}

# ECSタスク実行ロール用のIAMポリシー
# Secret Manager用のIAMポリシー
resource "aws_iam_policy" "ecs_task_execution_policy" {
  name        = "ecs_task_execution_policy"
  description = "Policy for ECS Task Execution"
  policy      = <<-EOT
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "secretsmanager:GetSecretValue"
        ],
        "Resource": "*"
      }
    ]
  }
  EOT
}

# RDSモニタリング用のIAMポリシー
data "aws_iam_policy_document" "rds-monitoring-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

# RDSモニタリング用のIAMロール
resource "aws_iam_role" "rds-monitering-role" {
  name               = "rds-monitering-role"
  assume_role_policy = data.aws_iam_policy_document.rds-monitoring-assume-role.json
}

# RDSモニタリング用のIAMポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "rds-monitering-role" {
  role       = aws_iam_role.rds-monitering-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
