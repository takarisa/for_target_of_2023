resource "aws_acm_certificate" "example" {
  domain_name       = "*.example.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "example_us" {
  domain_name = "*.example.com"
  # ヴァージニアリージョンで作成
  provider          = aws.virginia
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
