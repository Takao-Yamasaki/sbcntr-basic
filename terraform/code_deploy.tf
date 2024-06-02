# CodeDeploy
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_deployment_group
# TODO: リソース名を変更すること: sbcntr-ecs-backend
resource "aws_codedeploy_app" "app-ecs-sbcntr-ecs-backend-cluster-sbcntr-ecs-backend-service" {
  compute_platform = "ECS"
  name             = "sbcntr-backend"
}

# CodeDeployデプロイメントグループ
# BlueGreenデプロイメント
# TODO: リソース名を変更すること: sbcntr-ecs-backend-deployment-group
resource "aws_codedeploy_deployment_group" "dgp-ecs-sbcntr-ecs-backend-cluster-sbcntr-ecs-backend-service" {
  app_name               = aws_codedeploy_app.app-ecs-sbcntr-ecs-backend-cluster-sbcntr-ecs-backend-service.name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name  = "sbcntr-ecs-backend-deployment-group"
  service_role_arn       = aws_iam_role.ecs-codedeploy-role.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
      # トラフィック再ルーティングのタイムアウト設定を10分にする
      # wait_time_in_minutes = 10
    }

    terminate_blue_instances_on_deployment_success {
      action = "TERMINATE"
      # 切り替え後の待機時間は、1時間
      termination_wait_time_in_minutes = 60
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.sbcntr-ecs-backend-cluster.name
    service_name = aws_ecs_service.sbcntr-backend-service.name
  }

  load_balancer_info {
    target_group_pair_info {
      # プロダクションリスナーを指定
      prod_traffic_route {
        listener_arns = [aws_lb_listener.blue.arn]
      }
      # テストリスナーを指定
      test_traffic_route {
        listener_arns = [aws_lb_listener.green.arn]
      }

      target_group {
        name = aws_lb_target_group.sbcntr-tg-sbcntrdemo-blue.name
      }

      target_group {
        name = aws_lb_target_group.sbcntr-tg-sbcntrdemo-green.name
      }
    }
  }
}
