# 概要

管理用のEC2インスタンスにアタッチするためのTerraformコードです。  
必要に応じて権限の追加や削除を実施してください。

### 権限一覧
- S3/CloudFront/ECS/ECRのフルアクセス操作
- 全AWSリソースの読み取り権限（TerraformやAWS CDKのplan実行のため）
- SSM Session Managerからのログイン
- Assume Roleの許可
- RDSのスナップショット作成
