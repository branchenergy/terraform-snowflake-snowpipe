output "topic_arn" {
  value = var.add_pipe ? aws_sns_topic.this.arn : null
}
