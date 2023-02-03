variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "prefix_tables" {
  type = map(
    object({
      table_name     = string
      file_format    = optional(string)
      copy_statement = optional(string)
      add_pipe       = optional(bool, true)
    })
  )
  description = <<-EOT
    A mapping from an S3 bucket prefix to the Snowflake table which it
    should be loaded; `table_name` is required and the following
    variables are optional:

    - `file_format`, for the stage; if not given uses the `file_format` variable to the
      parent module
    - `copy_statement`, if not given uses a basic `COPY INTO [table] FROM @[stage]`
    - `add_pipe`, default `true`, to show that the SNS topic and autoingesting
      pipe should be used; set to `false` if you plan to use manual `COPY` statement.
      In this case, 
  EOT
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
  description = "Stage file format name used for tables without a custom `file_format` set"
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
