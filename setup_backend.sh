#!/bin/bash

cd /home/ec2-user/environment
git clone https://github.com/uma-arai/sbcntr-backend.git
cd /home/ec2-user/environment/sbcntr-backend

### Docker ######
# イメージのビルド
docker image build -t sbcntr-backend:v1 .
docker image ls --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
# イメージへのタグ付け
docker image tag sbcntr-backend:v1 ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-backend:v1
# Dockerへの認証
aws ecr --region ap-northeast-1 get-login-password | docker login --username AWS --password-stdin https://${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-backend
# イメージのプッシュ
docker image push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-backend:v1
# ビルド済みのイメージを削除
docker image rm -f $(docker image ls -q)
# イメージの取得
docker image pull ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-backend:v1
