output "topic_arn" {
  description = "The ARN of the SNS Topic"
  value       = aws_sns_topic.this.arn
}

output "topic_id" {
  description = "The ID of the SNS Topic"
  value       = aws_sns_topic.this.id
}

output "payload_bucket_id" {
  description = "The S3-bucket ID created in this module."
  value       = aws_s3_bucket.large_message_payload[*].id
}

output "payload_bucket_arn" {
  description = "The S3-bucket ARN created in this module."
  value       = aws_s3_bucket.large_message_payload[*].arn
}
