#!/bin/bash

# 対象イメージの取得
docker image pull golang:1.16.8-alpine3.13
docker image ls --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}"
# 取得したalpineイメージをECRに格納
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
# Dockerへの認証
aws ecr --region ap-northeast-1 get-login-password | docker login --username AWS --password-stdin https://${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-base
# イメージへのタグ付け
docker image tag golang:1.16.8-alpine3.13 ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-base:golang1.16.8-alpine3.13
# イメージのプッシュ
docker image push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-base:golang1.16.8-alpine3.13
