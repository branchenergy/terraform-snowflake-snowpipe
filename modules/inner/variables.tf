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

variable "copy_statement" {
  type        = string
  description = "Optional copy statement for the pipe; if not given, uses `COPY INTO [table] FROM @[stage]"
  default     = null
  nullable    = true
}

variable "storage_integration" {
  type        = string
  description = "Snowflake storage integration name"
}

variable "storage_aws_iam_user_arn" {
  type        = string
  description = "Snowflake storage integration's `STORAGE_AWS_IAM_USER_ARN` property"
}
