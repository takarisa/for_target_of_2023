resource "aws_wafv2_ip_set" "example" {
  name = "example"
  scope              = "CLOUDFRONT"
  # ヴァージニアリージョンで作成
  provider = aws.virginia
  ip_address_version = "IPV4"
  addresses = ["192.168.1.0/24"]
}

resource "aws_wafv2_web_acl" "example" {
  name = "example"
  scope              = "CLOUDFRONT"
  # ヴァージニアリージョンで作成
  provider = aws.virginia
  default_action {
    block {}
  }
  rule {
    name     = "example"
    priority = 10
    action {
      allow {}
    }
    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.example.arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "example"
      sampled_requests_enabled   = true
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "example"
    sampled_requests_enabled   = true
  }
}