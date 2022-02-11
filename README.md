# Snowpipe

This repository houses a Terraform module for creating automatically-ingesting Snowflake
pipes from S3. In particular_, it implements [Option 2](https://docs.snowflake.com/en/user-guide/data-load-snowpipe-auto-s3.html#option-2-configuring-amazon-sns-to-automate-snowpipe-using-sqs-notifications)
of the _Automating Snowpipe for Amazon S3_ Snowflake documentation, creating an SNS
topic for each prefix

## Important Notes and Requirements

The following points were hard-won lessons for us, and important to understand for working with this
module. Nota bene.

- Each S3 bucket can only have a single notification configuration.
  [Look, it's right here in the docs!](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification)
  If you have an existing notification configuration for this bucket, this process will work, but
  it'll wipe out everything that already exists and you'll probably upset someone, possibly your
  future self.
- There is a 72 hour lag between the deletion of an SNS topic subscription and being able to
  resubscribe to it.
  [Look, that's right here in the docs too!](https://docs.snowflake.com/en/user-guide/data-load-snowpipe-ts.html#snowpipe-stops-loading-files-after-amazon-sns-topic-subscription-is-deleted)
  This can happen on the AWS side (by deleting the topic or subscription) _or_ on the Snowflake side
  (by deleting the pipe); for that reason we have `prevent_destroy = true` set on the SNS topic
  and policy, and the Snowflake pipe, in the module. If you really want to get rid of these you
  will have to do so manually. *Note*, however, that the _notifications_ (defined by the
  `aws_s3_bucket_notification` resource) _can_ be recreated, and will be if you pass a
  different/updated mapping in the `prefix_tables` variable (which we do often because we keep this
  alphabetically ordered).


### Requirements

This module relies on the following being true to keep things as simple as possible:

- All Snowflake objects exist/are created under the same database and schema: the tables,
  file format, stages and pipes
- All files share the same file format
- All copy statements are defined as a simple
  ```sql
  COPY INTO [DATABASE].[SCHEMA].[TABLE_NAME]
  FROM @[DATABASE].[SCHEMA].STAGE_[TABLE_NAME]
  ```
- We grant Snowflake `s3:GetObject` and `s3:GetObjectVersion` to _all_ objects in the S3 bucket
- Prefixes don't overlap with one-another; so you can't have `interesting-files/` as one prefix
  and `/interesting-files/first-set` as another prefix; we haven't tested this, but it seems like a
  bad idea


## Variables

The following variables need to be passed to the module for it to work (we'll go through these in detail!):

| Name                             | Type          | Description                                                                                                                           |
|----------------------------------|---------------|---------------------------------------------------------------------------------------------------------------------------------------|
| `bucket_name`                    | `string`      | S3 bucket name                                                                                                                        |
| `prefix_tables`                  | `map(string)` | A mapping from *prefix* to *table* name, giving the S3 prefix under which the data files will be auto-ingested into the table 'table' |
| `database`                       | `string`      | Target database name                                                                                                                  |
| `schema`                         | `string`      | Target schema name                                                                                                                    |
| `file_format`                    | `string`      | Snowflake file format used for the files under each prefix. **All files _must_ share the same file format!**                          |
| `storage_integration`            | `string`      | Snowflake storage integration's name                                                                                                  |
| `storage_aws_iam_user_arn`       | `string`      | Snowflake storage integration's `STORAGE_AWS_IAM_USER_ARN` property                                                                   |
| `storage_aws_external_id`        | `string`      | Snowflake storage integration's `STORAGE_AWS_EXTERNAL_ID` property                                                                    |
| `snowflake_role_path`            | `string`      | AWS IAM path for the Snowflake role                                                                                                   |
| `snowflake_role_name`            | `string`      | AWS IAM name for the Snowflake role                                                                                                   |


## Usage Steps

### Step 1: Snowflake Role Path, Name and ARN

The role path and name are crucially important because we use them for creating the Snowflake
integration in Step 2. It doesn't matter what they are, as long as they make sense and don't
conflict with a preexisting role. Ours are `/data/data-feeds/` and `snowflake-integration`,
respectively.

Once decided, the role ARN will be:

`arn:aws:iam::[AWS account #]:role[role path][role name]`

See [here](https://docs.aws.amazon.com/IAM/latest/UserGuide/console_account-alias.html) on how to
find your AWS account number.

### Step 2: Create the Storage Integration on Snowflake

Once the IAM role ARN is decided, you can create a storage integration for the S3 bucket by
following [the section in the Snowflake docs](https://docs.snowflake.com/en/user-guide/data-load-snowpipe-auto-s3.html#step-3-create-a-cloud-storage-integration-in-snowflake);
`STORAGE_AWS_ROLE_ARN` is the value of the role ARN. We don't do this in Terraform because by
default it's only possible for an account admin to do this.

Having been created, you then need to:

- Run `DESCRIBE INTEGRATION <integration_name>;` in Snowflake to get the `STORAGE_AWS_IAM_USER_ARN`
  and `STORAGE_AWS_EXTERNAL_ID` property values
- Run `GRANT USAGE ON INTEGRATION <integration_name> TO ROLE <blah>;` in Snowflake, granting
  permissions to the role that will be creating the stage and the pipe

### Step 3: Define the Prefix-Table mapping

We do this in a YAML file and load it into a variable with `yamldecode(file("prefix-tables.yaml")`
in Terraform. In fact, we just define a list of tables and define the mapping using:

```hcl
locals {
  tables         = yamldecode(file("tables.yaml")
  prefix_tables  = {
    for table in local.tables : "${table}/" => table
  }
}
```

As a result, we always load files from `{prefix}/` into `{table}`, so we don't have to remember
which tables are loaded by which prefixes.

### Step 4: Rock and Roll

From there, it is a simple case of creating an instance of the module and passing the above
variables to it.
