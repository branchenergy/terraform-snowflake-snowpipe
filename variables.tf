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
  type = map(string)
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
  description = "Stage file format name"
  type        = string
}

variable "snowflake_external_account_arn" {
  description = "Snowflake user external account ARN to subscribe to the topic"
  type        = string
}
