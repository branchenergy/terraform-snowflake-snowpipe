# Terraform config
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.54"
    }

    snowflake = {
      source  = "chanzuckerberg/snowflake"
      version = "~> 0.25.24"
    }
  }

  required_version = ">= 0.14.9"
  experiments      = [module_variable_optional_attrs]
}

data "aws_caller_identity" "current" {}


locals {
  table_name_lower = lower(var.table_name)
  bucket_url       = replace(var.bucket_arn, "arn:aws:s3:::", "s3://")
  stage_name       = "STAGE_${upper(var.table_name)}"
  stage_url        = "${local.bucket_url}/${var.prefix}"
  pipe_name        = "PIPE_${upper(var.table_name)}"
  topic_name       = join("-", ["s3-snowpipe", replace(local.table_name_lower, "_", "-")])
  topic_arn        = "arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:${local.topic_name}"
}

resource "aws_sns_topic" "this" {
  name = local.topic_name

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_sns_topic_policy" "this" {
  arn    = aws_sns_topic.this.arn
  policy = data.aws_iam_policy_document.this.json

  lifecycle {
    prevent_destroy = true
  }
}


data "aws_iam_policy_document" "this" {

  policy_id = "__default_policy_ID"

  # The AWS account itself can do anything...
  statement {
    effect = "Allow"
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]
    resources = [aws_sns_topic.this.arn]

    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "aws:SourceOwner"
    }

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    sid = "__default_statement_ID"
  }

  # The bucket can publish to the topic
  statement {
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.this.arn]
    principals {
      identifiers = ["s3.amazonaws.com"]
      type        = "Service"
    }
    condition {
      test     = "ArnLike"
      values   = [var.bucket_arn]
      variable = "aws:SourceArn"
    }

    sid = "s3-publish"
  }

  # Snowflake can subscribe to it
  statement {
    effect    = "Allow"
    actions   = ["sns:Subscribe"]
    resources = [aws_sns_topic.this.arn]
    principals {
      identifiers = [var.storage_aws_iam_user_arn]
      type        = "AWS"
    }

    sid = "snowflake-subscribe"
  }
}

resource "snowflake_stage" "this" {
  name     = local.stage_name
  url      = local.stage_url
  database = var.database
  schema   = var.schema

  storage_integration = var.storage_integration
  file_format         = "FORMAT_NAME = ${var.database}.${var.schema}.${var.file_format}"

  depends_on = [aws_sns_topic_policy.this]
}

resource "snowflake_pipe" "pipe" {
  database = var.database
  schema   = var.schema
  name     = local.pipe_name

  comment           = "${var.table_name} pipe"
  copy_statement    = upper("copy into ${var.database}.${var.schema}.${var.table_name} from @${var.database}.${var.schema}.${local.stage_name}")
  auto_ingest       = true
  aws_sns_topic_arn = local.topic_arn

  depends_on = [snowflake_stage.this]

  lifecycle {
    prevent_destroy = true
  }
}
