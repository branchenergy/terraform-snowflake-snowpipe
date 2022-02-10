output "id" {
  value = snowflake_table.this.id
}

output "table" {
  value = snowflake_table.this
}

output "topic_arn" {
  value = aws_sns_topic.this.arn
}
