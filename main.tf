resource "aws_sns_topic" "this" {
  name = var.name
}

data "aws_organizations_organization" "current" {}

data "aws_iam_policy_document" "vy_org_subscribers" {
  # Allow vy organization to subscribe to the topic
  statement {
    sid = "AllowVyOrganization"

    effect = "Allow"

    actions   = ["SNS:Subscribe"]
    resources = [aws_sns_topic.this.arn]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [data.aws_organizations_organization.current.id]
    }
  }
}

data "aws_iam_policy_document" "external_subscribers" {
  source_policy_documents = var.allow_anyone_in_organization_to_subscribe ? [
    data.aws_iam_policy_document.vy_org_subscribers.json
  ] : []

  statement {
    sid = "AllowExternalSubscribers"

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = formatlist("arn:aws:iam::%s:root", var.allowed_external_subscribers)
    }

    actions = ["SNS:Subscribe"]

    resources = [aws_sns_topic.this.arn]
  }
}


locals {
  should_apply_policies = length(var.allowed_external_subscribers) > 0 || var.allow_anyone_in_organization_to_subscribe
}

resource "aws_sns_topic_policy" "external_subscribers" {
  count = local.should_apply_policies ? 1 : 0

  arn    = aws_sns_topic.this.arn
  policy = data.aws_iam_policy_document.external_subscribers.json
}

# == S3 Payload Bucket for large messages ==
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

data "aws_iam_policy_document" "allow_organization_read" {
  count = var.create_payload_bucket ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = data.aws_organizations_organization.current.arn
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

data "aws_iam_policy_document" "allow_external_read" {
  count = var.create_payload_bucket ? 1 : 0

  source_policy_documents = var.allow_anyone_in_organization_to_subscribe ? [
    data.aws_iam_policy_document.allow_organization_read[0].json
  ] : []

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

resource "aws_s3_bucket_policy" "allow_external_read" {
  count = var.create_payload_bucket && local.should_apply_policies ? 1 : 0

  bucket = aws_s3_bucket.large_message_payload[0].id
  policy = data.aws_iam_policy_document.allow_external_read[0].json
}
