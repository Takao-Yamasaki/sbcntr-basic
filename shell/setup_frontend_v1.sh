#!/bin/bash

cd /home/ec2-user/environment
git clone https://github.com/uma-arai/sbcntr-frontend.git
cd /home/ec2-user/environment/sbcntr-frontend
# ブランチを変更
git checkout feature/#helloworld
# nvmのインストール
npm i -g nvm
# v14系のLTS版が存在することを確認
nvm ls-remote | grep v14.16.1
nvm install v14.16.1
# デフォルトのバージョンをv14.16.1に変更
nvm alias default v14.16.1
# node14系に切り替わったことを確認
node -v
# yarnのインストール
npm i -g yarn
# yarnのインストールを確認
yarn -v
# 各モジュールのインストール
yarn install --pure-lockfile --production
# Blitzがインストールされたことを確認
npx blitz -v

### Docker ######
cd /home/ec2-user/environment/sbcntr-frontend
docker image build -t sbcntr-frontend .
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
docker image tag sbcntr-frontend:latest ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-frontend:v1
aws ecr --region ap-northeast-1 get-login-password | docker login --username AWS --password-stdin https://${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-frontend
docker image push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-frontend:v1
