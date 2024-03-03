# TODO: 初回apply後、コメントアウト解除すること

# タスク定義の作成
resource "aws_ecs_task_definition" "sbcntr-backend-def" {
  family = "sbcntr-backend-def"

  # https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/task-cpu-memory-error.html
  cpu = "512" # 0.5vCPU
  memory = "1024" # 1 GB = 1024 MiB
  
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  # タスク実行ロール
  execution_role_arn = aws_iam_role.ecs-task-execution-role.arn
  # タスクロール
  task_role_arn = aws_iam_role.ecs-task-execution-role.arn
  container_definitions = jsonencode([
    {
      name = "app",
      image = "${data.aws_caller_identity.self.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-backend:v1",
      memory = 512,
      essential = true, # タスク実行に必要かどうか
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group = "/ecs/app",
          awslogs-region = "ap-northeast-1"
          awslogs-stream-prefix = "ecs"
        }
      }
      portMappings = [
        {
          protocol = "tcp",
          containerPort = 80,
          hostPort = 80,
        }
      ]
    }
  ])
}

# ECSクラスターの作成
resource "aws_ecs_cluster" "sbcntr-ecs-backend-cluster" {
  name = "sbcntr-ecs-backend-cluster"
}

# ECSサービスの作成
# ALBと連携してタスク動作をコントロールする
resource "aws_ecs_service" "sbcntr-backend-service" {
  name = "sbcntr-backend-service"
  cluster = aws_ecs_cluster.sbcntr-ecs-backend-cluster.arn
  task_definition = aws_ecs_task_definition.sbcntr-backend-def.arn
  launch_type = "FARGATE"
  platform_version = "1.4.0"
  # タスクの数
  desired_count = 2

  # ECSで管理されたタグを有効化
  enable_ecs_managed_tags = true

  # タスク状態の伝達の有効化
  propagate_tags = "TASK_DEFINITION"

  # 最小ヘルス率
  deployment_minimum_healthy_percent = 100
  # 最大率
  deployment_maximum_percent = 200
  # デプロイサーキットブレーカーを無効にする
  deployment_circuit_breaker {
    enable = false
    rollback = false
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }
  
  # ヘルスチェックの猶予期間
  health_check_grace_period_seconds = 120
  # ECS Exec を有効化
  enable_execute_command = true

  network_configuration {
    # パブリックIPの自動割り当てを無効化
    assign_public_ip = false
    security_groups = [
      aws_security_group.sbcntr-sg-container.id
    ]

    subnets = [
      aws_subnet.sbcntr-subnet-private-container-1a.id,
      aws_subnet.sbcntr-subnet-private-container-1c.id
    ]
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.sbcntr-tg-sbcntrdemo-blue.arn
    container_name = "app"
    container_port = 80
  }

  # サービス検出の設定
  service_registries {
    registry_arn = aws_service_discovery_service.sbcntr-ecs-backend-service.arn
  }
  
  # 依存関係
  depends_on = [ 
    aws_ecs_task_definition.sbcntr-backend-def, 
    aws_iam_role.ecs-codedeploy-role, # NOTE: 使うのか不明。不要な場合は削除
    aws_service_discovery_service.sbcntr-ecs-backend-service
  ]
}

# 名前空間の設定
resource "aws_service_discovery_private_dns_namespace" "sbcntr-ecs-backend-service" {
  name = "local"
  description = "local"
  vpc = aws_vpc.sbcntr-vpc.id
}

# ECSサービスのサービス検出の設定
resource "aws_service_discovery_service" "sbcntr-ecs-backend-service" {
  name = "sbcntr-ecs-backend-service"
  
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.sbcntr-ecs-backend-service.id

    dns_records {
      ttl = 60
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
}
