# sbcntr-basic

## 環境構築方法
```
terraform apply
```
## Cloud9の環境構築
terraformで環境構築後、以下の手順を実行する
### セキュリティグループの追加
- マネジメントコンソールから、Cloud9に使用しているEC2に`sbcntr-sg-management`というセキュリティグループを追加する
### Cloud9の空き領域の確保
- EC2インスタンスの`[インスタンスメタデータオプションの変更][インスタンスメタデータサービス]`を有効化し、`[IMDSv2]`をOptionalに変更する
- Cloud9の空き容量の確保のため、次のコマンドで、シェルスクリプトを実行する
```
$ sh resize.sh 30
```
公式サイトにも記載あり
- https://docs.aws.amazon.com/ja_jp/cloud9/latest/user-guide/move-environment.html
### IAMロールの変更
- Cloud9に使用しているEC2のIAMロールを`sbcntr-cloud9-role`に変更して、IDE内の`[AWS Settings]``[Credentials]`からAMTCを無効化する(EC2起動時にしかプロファイルを変更できないため、要注意)
## アプリケーションの環境構築
- フロントエンド
```
$ chmod 755 setup_frontend.sh
$ ./setup_frontend.sh
```
- バックエンド
```
$ chmod 755 setup_backend.sh
$ ./setup_backend.sh
```
- イメージのビルド
```
$ cd /home/ec2-user/environment/sbcntr-backend
$ docker image build -t sbcntr-backend:v1 .
$ docker image ls --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}"
$ AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
$ docker image tag sbcntr-backend:v1 ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-backend:v1
$ aws ecr --region ap-northeast-1 get-login-password | docker login --username AWS --password-stdin https://${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-backend
```


## 参考
https://www.sbcr.jp/support/4815609994/
