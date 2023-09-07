resource "aws_sns_topic" "this" {
  name = var.name
}

data "aws_iam_policy_document" "external_subscribers" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = formatlist("arn:aws:iam::%s:root", var.allowed_external_subscribers)
    }

    actions = ["SNS:Subscribe"]

    resources = [aws_sns_topic.this.arn]
  }
}

resource "aws_sns_topic_policy" "external_subscribers" {
  count = length(var.allowed_external_subscribers) > 0 ? 1 : 0

  arn    = aws_sns_topic.this.arn
  policy = data.aws_iam_policy_document.external_subscribers.json
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "large_message_payload" {
  count  = var.create_payload_bucket ? 1 : 0
  bucket = "${data.aws_caller_identity.current.account_id}-sns-payloads-for-${var.name}"
}

resource "aws_s3_bucket_lifecycle_configuration" "large_messages_bucket_lifecycle_configuration" {
  count  = var.create_payload_bucket ? 1 : 0
  bucket = aws_s3_bucket.large_message_payload[0].id
  rule {
    id     = "object-expiration"
    status = "Enabled"
    expiration {
      days = var.payload_bucket_expiration_days
    }
  }
}

resource "aws_s3_bucket_policy" "allow_external_read" {
  count  = var.create_payload_bucket && length(var.allowed_external_subscribers) > 0 ? 1 : 0
  bucket = aws_s3_bucket.large_message_payload[0].id
  policy = data.aws_iam_policy_document.allow_external_read[0].json
}

data "aws_iam_policy_document" "allow_external_read" {
  count = var.create_payload_bucket == true ? 1 : 0
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = formatlist("arn:aws:iam::%s:root", var.allowed_external_subscribers)
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.large_message_payload[0].arn,
      "${aws_s3_bucket.large_message_payload[0].arn}/*",
    ]
  }
}
