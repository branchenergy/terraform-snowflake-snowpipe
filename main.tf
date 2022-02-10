locals {
  notification_inputs = {
    for prefix, table in var.prefix_tables : prefix => {
      id            = "Saving ${table} table inputs from ${prefix}"
      topic_arn     = module.snowflake[prefix].topic_arn
      filter_prefix = prefix
    }
  }
}


module "snowpipe" {
  for_each                       = var.prefix_tables
  source                         = "./snowpipe"
  region                         = var.region
  bucket_arn                     = var.bucket_arn
  bucket_id                      = var.bucket_id
  prefix                         = each.key
  database                       = var.database
  schema                         = var.schema
  table_name                     = each.value
  file_format                    = var.file_format
  snowflake_external_account_arn = var.snowflake_external_account_arn
}

resource "aws_s3_bucket_notification" "this" {
  depends_on = [module.snowpipe]

  bucket = var.bucket_id

  dynamic "topic" {
    for_each = local.notification_inputs
    content {
      id            = topic.value["id"]
      topic_arn     = topic.value["topic_arn"]
      events        = ["s3:ObjectCreated:*"]
      filter_prefix = topic.value["filter_prefix"]
    }
  }
}
