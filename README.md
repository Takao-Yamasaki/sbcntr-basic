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
- Cloud9の空き容量の確保のため、次のコマンドで、シェルスクリプトを実行する
```
sh resize.sh 30
```
### IAMロールの変更
- Cloud9に使用しているEC2のIAMロールを`sbcntr-cloud9-role`に変更して、IDE内の`[AWS Settings]``[Credentials]`からAMTCを無効化する(EC2起動時にしかプロファイルを変更できないため、要注意)

## フロントエンド
```
$ git clone https://github.com/uma-arai/sbcntr-frontend.git
```
## バックエンド
```
$ git clone https://github.com/uma-arai/sbcntr-backend.git
```

## 参考
https://www.sbcr.jp/support/4815609994/
