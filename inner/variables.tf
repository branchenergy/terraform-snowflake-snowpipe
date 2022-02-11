variable "environment" {
  description = "Current environment"
  type        = string
}

variable "bucket_arn" {
  description = "S3 bucket arn"
  type        = string
}

variable "bucket_id" {
  description = "S3 bucket ID"
  type        = string
}

variable "prefix" {
  description = "S3 bucket prefix for which the Snowflake stage will be created"
  type        = string
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

variable "storage_aws_external_id" {
  type        = string
  description = "Snowflake storage integration's `STORAGE_AWS_EXTERNAL_ID` property"
}

variable "snowflake_role_path" {
  type        = string
  description = "Snowflake role path"
}

variable "snowflake_role_name" {
  type        = string
  description = "Snowflake role name"
}
