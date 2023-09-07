moved {
  from = aws_sns_topic.sns_topic
  to   = aws_sns_topic.this
}

moved {
  from = aws_sns_topic_policy.sns_topic_policy
  to   = aws_sns_topic_policy.external_subscribers
}
