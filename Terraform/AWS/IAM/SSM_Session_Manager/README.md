# 概要

管理権限を持たない開発会社や委託先向けIAMユーザに、SSMのSession ManagerからEC2へログインできるようにするTerraformコードです。  

SSM Session Managerからログインするメリット
- 踏み台サーバが不要
- アクセスキー＋多要素認証でログインするため、SSH鍵ログインよりもセキュア
- SSH鍵に相当するクレデンシャルを各サーバに配置不要
- ユーザ管理をIAMから一元管理できる
- ログインするOSのUNIXユーザの指定が可能

### 前提

- Session Managerの設定内の`General preferences`のRun Asを有効化していること。
- 接続先EC2のOSにSSM Agentがインストール済みであること。
- 接続先EC2のインスタンスプロファイルにAmazonSSMManagedInstanceCoreポリシー（あるいはそれ相当）がアタッチされていること。
- ログインするIAMユーザは多要素認証(MFA)を有効化していること。

# ログイン手順

### アクセスキーを発行

`IAM > ユーザー`の`セキュリティ認証情報`の`アクセスキーを作成`からアクセスキーを発行する。

### 多要素認証(MFA)を有効化

`IAM > ユーザー`の`セキュリティ認証情報`の`MFAデバイスの割り当て`から設定する。  
設定後、MFAのARNを控えておく。

### AWS CLIの設定

端末にaws cliをインストールする。  
インストール後、`.aws/config`及び`.aws/credentials`を参考にMFAやロールのARN、アクセスキーを記載する。

### EC2へログイン

以下コマンドからEC2ログインする。
```
aws ssm start-session --profile EXAMPLE --target <インスタンスID>
```

SSMではログインシェルがshになるため、必要に応じてBash等に変更すること。  
※ 使用しているOSが限られていてコンソールシェルのパスがすべて同じなら、`Session Manager`の設定内の`Shell profiles`で事前に定義することも可能。
