output "topic_arn" {
  value = aws_sns_topic.this.arn
}

output "snowflake_stage" {
  value = snowflake_stage.this
}