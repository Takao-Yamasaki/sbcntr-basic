# sbcntr-basic

## 環境の構築方法
```
terraform apply
```
## Cloud9の環境構築
terraformで環境構築後、以下の手順を実行する
### セキュリティグループの追加
- マネジメントコンソールから、Cloud9に使用しているEC2に`sbcntr-sg-management`というセキュリティグループを追加する
### IAMロールの変更
- Cloud9に使用しているEC2のIAMロールを`sbcntr-cloud9-role`に変更して、IDE内の`[AWS Settings]``[Credentials]`からAMTCを無効化する(EC2起動時にしかプロファイルを変更できないため、要注意)
```
aws configure list
```
### Cloud9の空き領域の確保
- (注意)EBSボリュームを`30GB`に変更した上で、インスタンスを再起動すると、ディスクを再認識するようで、こちらの方法のほうが早いかもしれない
- EC2インスタンスの`[インスタンスメタデータオプションの変更][インスタンスメタデータサービス]`を有効化し、`[IMDSv2]`をOptionalに変更する
- Cloud9の空き容量の確保のため、次のコマンドで、シェルスクリプトを実行する
```
# 空き領域の確認
$ df -h
$ sh resize.sh 30
```
公式サイトにも記載あり
- https://docs.aws.amazon.com/ja_jp/cloud9/latest/user-guide/move-environment.html
- https://dev.classmethod.jp/articles/expand-the-disk-size-of-cloud9/
## アプリケーションの環境構築(イメージのビルドからイメージ登録まで)
- 1.フロントエンド
```
$ chmod 755 setup_frontend.sh
$ ./setup_frontend.sh
```
- 2.バックエンド
```
$ chmod 755 setup_backend.sh
$ ./setup_backend.sh
```
## 挙動確認
- バックエンド
```
# コンテナを起動
$ docker container run -d -p 8080:80 ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-backend:v1
# APIサーバーにリクエスト送信
$ date; curl http://localhost:8080/v1/helloworld
```
- バックエンドアプリケーションへのALB経由の疎通確認
```
$ curl http://<ALBのDNS名>:80/v1/helloworld
{"data":"Hello world"}
```
- フロントエンドの挙動確認
TODO: ここから実装すること

## 環境の削除
- (注意)ECRのイメージを事前に削除すること
```
terraform destroy 
```
## 参考
https://www.sbcr.jp/support/4815609994/
