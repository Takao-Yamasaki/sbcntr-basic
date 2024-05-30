# カスタマー管理ポリシーの作成
## Cloud9からECRにアクセスするためのポリシー
resource "aws_iam_policy" "sbcntr-accessing-ecr-repository-policy" {
  name        = "sbcntr-AccessingECRRepositoryPolicy"
  description = "Policy to access ECR repo from Cloud9 instance"
  policy      = <<-EOT
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListImagesInRepository",
            "Effect": "Allow",
            "Action": [
                "ecr:ListImages"
            ],
            "Resource": [
                "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.self.account_id}:repository/sbcntr-backend",
                "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.self.account_id}:repository/sbcntr-frontend"
            ]
        },
        {
            "Sid": "GetAuthorizationToken",
            "Effect": "Allow",
            "Action": "ecr:GetAuthorizationToken",
            "Resource": "*"
        },
        {
            "Sid": "ManageRepositoryContents",
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
                "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.self.account_id}:repository/sbcntr-backend",
                "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.self.account_id}:repository/sbcntr-frontend"
            ]
        },
    ]
  }
  EOT
}

# カスタマー管理ポリシーの作成
## Cloud9からCodeCommitにアクセスするためのポリシー
resource "aws_iam_policy" "sbcntr-accessing-codecommit-policy" {
  name = "sbcntr-AccessingCodeCommitPolicy"
  policy      = <<-EOT
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "codecommit:BatchGet",
                "codecommit:BatchDescribe*",
                "codecommit:Describe*",
                "codecommit:Get*",
                "codecommit:List*",
                "codecommit:Merge*",
                "codecommit:Put*",
                "codecommit:Post*",
                "codecommit:Update*",
                "codecommit:GitPull*",
                "codecommit:GitPush**",
            ],
            "Resource": [
                "arn:aws:codecommit:${var.aws_region}:${data.aws_caller_identity.self.account_id}:sbcntr-backend",
            ]
        }
    ]
  }
  EOT
}

# IAMポリシードキュメント（Cloud9）
data "aws_iam_policy_document" "sbcntr-cloud9-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# IAMロールの作成（Cloud9）
## Cloud9からECRにアクセスするためのIAMロール
resource "aws_iam_role" "sbcntr-cloud9-role" {
  name        = "sbcntr-cloud9-role"
  description = "Allow EC2 instance to call AWS services on your behalf."
  # 信頼関係の設定
  assume_role_policy = data.aws_iam_policy_document.sbcntr-cloud9-assume-role.json

}

# sbcntr-AccessingECRRepositoryPolicyをアタッチ
resource "aws_iam_role_policy_attachment" "sbcntr-accessing-ecr-repository-policy" {
  role       = aws_iam_role.sbcntr-cloud9-role.name
  policy_arn = aws_iam_policy.sbcntr-accessing-ecr-repository-policy.arn
}

# sbcntr-AccessingCodeCommitPolicyをアタッチ
resource "aws_iam_role_policy_attachment" "sbcntr-accessing-codecommit-policy" {
  role       = aws_iam_role.sbcntr-cloud9-role.name
  policy_arn = aws_iam_policy.sbcntr-accessing-codecommit-policy.arn
}


# AWS管理ポリシーのアタッチ(SSM)
resource "aws_iam_role_policy_attachment" "sbcntr-cloud9-ssm-instance-profile-policy" {
  role       = aws_iam_role.sbcntr-cloud9-role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCloud9SSMInstanceProfile"
}

# AWS管理ポリシーのアタッチ(ECR)
resource "aws_iam_role_policy_attachment" "sbcntr-cloud9-ec2-container-registory-policy" {
  role       = aws_iam_role.sbcntr-cloud9-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

# AWS管理ポリシーのアタッチ(EBS)
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

# IAMポリシードキュメント(Blue/Green)
data "aws_iam_policy_document" "ecs-codedeploy-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

# IAMロールの作成(Blue/Green)
resource "aws_iam_role" "ecs-codedeploy-role" {
  name        = "ecsCodeDeployRole"
  description = "Allow CodeDeploy to read S3 objects, invoke Lamda functions, publish to SNS topics, and update ECS services on your behalf."
  # 信頼関係の設定
  assume_role_policy = data.aws_iam_policy_document.ecs-codedeploy-assume-role.json
}

# AWS管理ポリシーのアタッチ(Blue/Green用)
resource "aws_iam_role_policy_attachment" "ecs-codedeploy-role-policy" {
  role       = aws_iam_role.ecs-codedeploy-role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

# IAMポリシードキュメント（ECSタスク実行ロール）
data "aws_iam_policy_document" "ecs-task-execution-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# IAMロールの作成（ECSタスク実行ロール）
resource "aws_iam_role" "ecs-task-execution-role" {
  name               = "ecsTaskExecutionRole"
  # 信頼関係の設定
  assume_role_policy = data.aws_iam_policy_document.ecs-task-execution-assume-role.json
}

# カスタマー管理ポリシーのアタッチ（ECSタスク実行ロール）
resource "aws_iam_role_policy_attachment" "ecs-task-execution-policy" {
  role       = aws_iam_role.ecs-task-execution-role.name
  policy_arn = aws_iam_policy.ecs_task_execution_policy.arn
}

# カスタマー管理ポリシーのアタッチ（Secret Manager）
resource "aws_iam_role_policy_attachment" "sbcntr-getting-secrets-policy" {
  role       = aws_iam_role.ecs-task-execution-role.name
  policy_arn = aws_iam_policy.sbcntr-getting-secrets-policy.arn
}

# カスタマー管理ポリシー(ECSタスク実行ロール)
resource "aws_iam_policy" "ecs-task-execution-policy" {
  name        = "ecsTaskExecutionPolicy"
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

# カスタマー管理ポリシーの作成（Secret Manager）
## Secrets Managerのシークレットを参照するため
resource "aws_iam_policy" "sbcntr-getting-secrets-policy" {
  name        = "sbcntr-GettingSecretsPolicy"
  policy      = <<-EOT
  {
    "Version": "2012-10-17",
    "Statement": [
        {
          "Sid": "GetSecretForECS",
          "Effect": "Allow",
          "Action": [
              "secretsmanager:GetSecretValue"
          ],
          "Resource": "*"
        }
    ]
  }
  EOT
}

# IAMポリシードキュメント（RDSモニタリング）
data "aws_iam_policy_document" "rds-monitoring-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

# IAMロールの作成（RDSモニタリング）
resource "aws_iam_role" "rds-monitering-role" {
  name               = "rds-monitering-role"
  assume_role_policy = data.aws_iam_policy_document.rds-monitoring-assume-role.json
}

# AWS管理ポリシーをアタッチ(RDSモニタリング)
resource "aws_iam_role_policy_attachment" "rds-monitering-role-policy" {
  role       = aws_iam_role.rds-monitering-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
