# アカウントIDを取得
data "aws_caller_identity" "self" {}

# IAMポリシーの作成
resource "aws_iam_policy" "sbcntr-accessing-ecr-repository-policy" {
  name = "sbcntr-accessing-ecr-repository-policy"
  description = "policy to access ecr repo from cloud9 instance"
  policy = <<-EOT
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
  name = "sbcntr-cloud9-role"
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
  role = aws_iam_role.sbcntr-cloud9-role.name
  policy_arn = aws_iam_policy.sbcntr-accessing-ecr-repository-policy.arn
}

# 既存のIAMポリシーのアタッチ(SSM用)
resource "aws_iam_role_policy_attachment" "sbcntr-cloud9-ssm-instance-profile" {
  role = aws_iam_role.sbcntr-cloud9-role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCloud9SSMInstanceProfile"
}

# IAMインスタンスプロファイルの定義
resource "aws_iam_instance_profile" "sbcntr-cloud9-role" {
  name = "sbcntr-cloud9-role"
  role = aws_iam_role.sbcntr-cloud9-role.name
}
