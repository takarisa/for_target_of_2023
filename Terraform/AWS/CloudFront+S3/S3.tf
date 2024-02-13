####################################
# prod Frontend Sorryページ用 Bucket
####################################
resource "aws_s3_bucket" "example_fe" {
  bucket = "example-fe"

  tags = {
    Name        = "example-fe"
    Environment = "prod"
    Account     = "open"
  }
}

resource "aws_s3_bucket_public_access_block" "example_fe" {
  bucket = aws_s3_bucket.example_fe.id
  # 全拒否の完全なPrivateバケットは以下の設定が必要
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# リソースを配置するのでVersioning有効にする
resource "aws_s3_bucket_versioning" "example_fe" {
  bucket = aws_s3_bucket.example_fe.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "example_fe" {
  bucket = aws_s3_bucket.example_fe.id
  policy = jsonencode(
    {
      "Version" : "2008-10-17",
      "Id" : "PolicyForCloudFrontPrivateContent",
      "Statement" : [
        {
          "Sid" : "AllowCloudFront",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "cloudfront.amazonaws.com"
          },
          "Action" : "s3:GetObject",
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.example_fe.id}/*"
          "Condition" : {
            "StringEquals" : {
              "AWS:SourceArn" : aws_cloudfront_distribution.example_fe_cf.arn
            }
          }
        }
      ]
    }
  )
}

####################################
# prod ティザーサイト用 Bucket
####################################
resource "aws_s3_bucket" "example" {
  bucket = "example"
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.id
  # 全拒否の完全なPrivateバケットは以下の設定が必要
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.example.bucket
  index_document {
    suffix = "index.html"
  }
  routing_rule {
    condition {
      http_error_code_returned_equals = "404"
    }
    redirect {
      host_name          = "symbiogenesis.app"
      http_redirect_code = "302"
      replace_key_with   = "."
    }
  }
}

resource "aws_s3_bucket_policy" "example" {
  bucket = aws_s3_bucket.example.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "PublicReadGetObject",
          "Effect" : "Allow",
          "Principal" : "*",
          "Action" : "s3:GetObject",
          "Resource" : "${aws_s3_bucket.example.arn}"
          "Condition" : {
            "StringEquals" : {
              "aws:Referer" : "${local.referer}"
            }
          }
        }
      ]
    }
  )
}

resource "aws_s3_bucket" "example_log" {
  bucket = "example-log"

  tags = {
    Name        = "example-log"
    Environment = "prod"
    Account     = "open"
  }
}

resource "aws_s3_bucket_public_access_block" "example_log" {
  bucket = aws_s3_bucket.example_log.id
  # 全拒否の完全なPrivateバケットは以下の設定が必要
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

## 2023/04のAWS側の変更でCFからS3にログを吐かせる場合、以下が必須に
resource "aws_s3_bucket_ownership_controls" "example_log" {
  bucket = aws_s3_bucket.example_log.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "example_log" {
  bucket = aws_s3_bucket.example_log.id
  rule {
    id     = "rule-example-log"
    status = "Enabled"
    # 1年で削除
    expiration {
      days = 365
    }
  }
  # NOTE 世代数管理したい場合は手動でしかできない為、下記を有効にする
  # lifecycle {
  #  ignore_changes = [
  #    rule["id"],
  #  ]
}
