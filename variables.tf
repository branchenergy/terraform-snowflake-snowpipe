variable "region" {
  type        = string
  description = "AWS region housing the bucket"
}

variable "bucket_arn" {
  description = "S3 bucket arn"
  type        = string
}

variable "bucket_id" {
  description = "S3 bucket ID"
  type        = string
}

variable "prefix_tables" {
  type        = map(string)
  description = "A mapping from an S3 bucket prefix to the Snowflake table name into which it should be loaded"
}

variable "database" {
  type        = string
  description = "Snowflake database name"
}

variable "schema" {
  type        = string
  description = "Snowflake database schema name"
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
