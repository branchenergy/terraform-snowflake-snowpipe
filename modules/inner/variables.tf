variable "region" {
  type        = string
  description = "S3 bucket region"
}

variable "bucket_arn" {
  type        = string
  description = "S3 bucket arn"
}

variable "bucket_id" {
  type        = string
  description = "S3 bucket ID"
}

variable "prefix" {
  type        = string
  description = "S3 bucket prefix for which the Snowflake stage will be created"
}

variable "database" {
  type        = string
  description = "Snowflake database name"
}

variable "schema" {
  type        = string
  description = "Snowflake database schema name"
}

variable "table_name" {
  type        = string
  description = "Snowflake table name"
}

variable "file_format" {
  type        = string
  description = "Stage file format name"
}

variable "storage_integration" {
  type        = string
  description = "Snowflake storage integration name"
}

variable "storage_aws_iam_user_arn" {
  type        = string
  description = "Snowflake storage integration's `STORAGE_AWS_IAM_USER_ARN` property"
}

variable "pipe_copy_statement"{
  type        = string
  default     = null
  description = <<-EOT
    Statement for copying data from the pipe into the table; by default

    `COPY INTO [database].[schema].[table_name] from @[database].[schema].[stage_name]`
  EOT
}