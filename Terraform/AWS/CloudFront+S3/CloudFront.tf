data "aws_cloudfront_origin_request_policy" "CORS-S3Origin" { name = "Managed-CORS-S3Origin" }

resource "aws_cloudfront_distribution" "example" {
  # WebホスティングS3
  origin {
    origin_id   = "example-s3-web"
    domain_name = aws_s3_bucket_website_configuration.example.website_endpoint
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "http-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_keepalive_timeout = 5
      origin_read_timeout      = 30
    }
    custom_header {
      name  = "Referer"
      # ランダム生成した文字列
      value = "bQ7WK4n3kjgC24ixbzmnba1e"
    }
  }
  # アセット＆Sorryページ用S3オリジン
  origin {
    origin_id                = "example-s3"
    domain_name              = aws_s3_bucket.example.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.example.id
  }
  aliases         = ["www.example.com"]
  enabled         = true
  is_ipv6_enabled = false
  price_class     = "PriceClass_All"
  http_version    = "http2"
  web_acl_id      = aws_wafv2_web_acl.example.arn
  # 優先度0のビヘイビア（デフォルト）
  default_cache_behavior {
    target_origin_id       = "example-s3-web"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = aws_cloudfront_cache_policy.example.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.example.id
  }
  # 優先度1のビヘイビア
  ordered_cache_behavior {
    path_pattern           = "/assets/*"
    target_origin_id       = "example-s3"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    # brotli/gzip圧縮を有効化
    compress        = true
    cache_policy_id        = aws_cloudfront_cache_policy.example_assets.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.example_assets.id
    origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.CORS-S3Origin.id
  }
  # 優先度2のビヘイビア
  ordered_cache_behavior {
    path_pattern           = "/sorry/*"
    target_origin_id       = "example-s3"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = aws_cloudfront_cache_policy.example_sorry.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.example_sorry.id
  }
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.example.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  dynamic "custom_error_response" {
    for_each = {
      400 = { path = "/sorry/40x.html" }
      403 = { path = "/sorry/40x.html" }
      404 = { path = "/sorry/40x.html" }
      404 = { path = "/sorry/40x.html" }
      414 = { path = "/sorry/40x.html" }
      416 = { path = "/sorry/40x.html" }
      500 = { path = "/sorry/50x.html" }
      501 = { path = "/sorry/50x.html" }
      502 = { path = "/sorry/50x.html" }
      503 = { path = "/sorry/50x.html" }
      504 = { path = "/sorry/50x.html" }
    }
    content {
      error_code            = custom_error_response.key
      error_caching_min_ttl = 0
      response_code         = custom_error_response.value.path == null ? null : custom_error_response.key
      response_page_path    = custom_error_response.value.path
    }
  }
  logging_config {
    bucket = aws_s3_bucket.example_log.id.bucket_domain_name
    # ログにクッキーを含める(default:False
    include_cookies = true
    prefix          = "example-log"
  }
}

resource "aws_cloudfront_origin_access_control" "example" {
  name                              = "example"
  description                       = "for example"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# モニタリングの追加機能
resource "aws_cloudfront_monitoring_subscription" "example" {
  distribution_id = aws_cloudfront_distribution.example.id
  monitoring_subscription {
    realtime_metrics_subscription_config {
      realtime_metrics_subscription_status = "Enabled"
    }
  }
}


###########################
#     S3 Web用ポリシー      #
###########################
resource "aws_cloudfront_cache_policy" "example" {
  name = "example"
  min_ttl     = 0
  max_ttl     = 0
  default_ttl = 0
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_response_headers_policy" "example" {
  name = "example"
  custom_headers_config {
    items {
      header   = "Cache-Control"
      value    = "no-cache"
      override = true
    }
  }
}


#############################
#     S3 Assets用ポリシー     #
#############################
resource "aws_cloudfront_cache_policy" "example_assets" {
  name = "example"
  min_ttl     = 3600
  max_ttl     = 3600
  default_ttl = 3600
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
}
resource "aws_cloudfront_response_headers_policy" "example_assets" {
  name = "example-assets"
  custom_headers_config {
    items {
      header   = "Cache-Control"
      value    = "max-age=3600"
      override = true
    }
  }
  cors_config {
    access_control_allow_credentials = false
    origin_override = true
    access_control_allow_headers {
      items = ["*"]
    }
    access_control_allow_methods {
      items = ["GET", "HEAD"]
    }
    access_control_allow_origins {
      items = [
        "*.example.com"
      ]
    }
  }
}
