# sbcntr-basic

## 資材
https://github.com/uma-arai/sbcntr-resources/blob/main/cloudformations/network_step1.yml

## Cloud9に使用しているEC2にセキュリティグループの追加
- 環境構築したら、手動で`sbcntr-sg-management`を追加する

## フロントエンド
```
$ git clone https://github.com/uma-arai/sbcntr-frontend.git
```
## バックエンド
```
$ git clone https://github.com/uma-arai/sbcntr-backend.git
```
## Cloud9の空き領域の確保
- シェルファイルの実行
```
sh resize.sh 30
```
https://www.sbcr.jp/support/4815609994/

## TODO: iamロールを作成すること
