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
  description = "Stage file format name"
  type        = string
}

variable "snowflake_external_account_arn" {
  description = "Snowflake user external account ARN to subscribe to the topic"
  type        = string
}
