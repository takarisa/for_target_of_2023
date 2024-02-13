resource "aws_iam_role" "example" {
  name = "example"
  # 最大セッション時間 8時間
  max_session_duration = 28800
  assume_role_policy   = file("./Role_example.json")
  # SSMでログインするときのOSユーザを指定
  tags = {
    SSMSessionRunAs = "username"
  }
}

resource "aws_iam_policy" "example" {
  name   = "example"
  policy = file("./Policy_example.json")
}

resource "aws_iam_role_policy_attachment" "example" {
  role       = aws_iam_role.example.name
  policy_arn = aws_iam_policy.example.arn
}
