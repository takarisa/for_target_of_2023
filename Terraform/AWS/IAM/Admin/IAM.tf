####################
#     IAM Role     #
####################
resource "aws_iam_role" "example" {
  name = "example"
  # 最大セッション時間 8時間
  max_session_duration = 28800
  assume_role_policy   = file("./Role.json")
}


######################
#     IAM Policy     #
######################
# Assumeroleを許可するポリシー
resource "aws_iam_policy" "example_assumerole" {
  name   = "example-assumerole"
  policy = file("./Policy_example-assumerole.json")
}
# RDSクラスタのスナップショットを作成するポリシー
resource "aws_iam_policy" "example_rds_snapshot" {
  name   = "example-rds-snapshot"
  policy = file("./Policy_example-rds-snapshot.json")
}
# ECRフルアクセス用ポリシー
resource "aws_iam_policy" "example_ecr" {
  name   = "example-ecr"
  policy = file("./Policy_example-ecr.json")
}
# Terraform実行時のエラー回避用ポリシー
resource "aws_iam_policy" "example_ecs" {
  name   = "example-ecs-list"
  policy = file("./Policy_example-ecs-list.json")
}



#################################
#     IAM Policy Attachment     #
#################################
# SSM Session ManagerからEC2へログインするためのポリシー
resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  role       = aws_iam_role.example.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
# S3用フルアクセスポリシー
resource "aws_iam_role_policy_attachment" "AmazonS3FullAccess" {
  role       = aws_iam_role.example.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
# CloudFront用フルアクセスポリシー
resource "aws_iam_role_policy_attachment" "CloudFrontFullAccess" {
  role       = aws_iam_role.example.name
  policy_arn = "arn:aws:iam::aws:policy/CloudFrontFullAccess"
}
# ECS用フルアクセスポリシー
resource "aws_iam_role_policy_attachment" "AmazonECS_FullAccess" {
  role       = aws_iam_role.example.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}
# 全リソースの読み取り用ポリシー
resource "aws_iam_role_policy_attachment" "ReadOnlyAccess" {
  role       = aws_iam_role.example.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
# カスタムポリシー
resource "aws_iam_role_policy_attachment" "example_assumerole" {
  role       = aws_iam_role.example.name
  policy_arn = aws_iam_policy.example_assumerole.arn
}
resource "aws_iam_role_policy_attachment" "example_rds_snapshot" {
  role       = aws_iam_role.example.name
  policy_arn = aws_iam_policy.example_rds_snapshot.arn
}
resource "aws_iam_role_policy_attachment" "example_ecr" {
  role       = aws_iam_role.example.name
  policy_arn = aws_iam_policy.example_ecr.arn
}
resource "aws_iam_role_policy_attachment" "example_ecs" {
  role       = aws_iam_role.example.name
  policy_arn = aws_iam_policy.example_ecs.arn
}


################################
#     IAM Instance Profile     #
################################
resource "aws_iam_instance_profile" "example" {
  name = "example"
  role = aws_iam_role.example.name
}
