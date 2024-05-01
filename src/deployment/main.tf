terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.47.0"
    }
  }
}

provider "aws" {
  region = var.REGION
}

# IAM policy/roles
resource "aws_iam_role" "Lambda-Emailing-Role" {
  name = "Lambda-Emailing-Role"

    assume_role_policy =  jsonencode({
        Version = "2012-10-17"
        Statement = [
    # CloudWatch Log
    {
    Action: [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
    ],
    Effect: "Allow",
    Resource: "arn:aws:logs:*:*:*"
    },
    # SNS
    {
    Action: [
        "sns:CreateTopic",
		"sns:Publish"
    ],
    Effect: "Allow",
    Resource: "arn:aws:sns:*:123456789012:new-product-topic"
    }
        ]
    })
}
# attach aws managed policy to custom role
resource "aws_iam_role_policy_attachment" "s3_read_only_access" {
  role = aws_iam_role.Lambda-Emailing-Role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}


# SNS
# "new-product-topic" for a reference in terraform code
# name = "new-product-topic" for a SNS-topic name on AWS
resource "aws_sns_topic" "new-product-topic" {
    name = var.TOPIC_NAME
    
}
# create subscription
resource "aws_sns_topic_subscription" "new-product-topic-subscription" {
  topic_arn = aws_sns_topic.new-product-topic.arn
  protocol = "email"

  for_each = toset(var.SUBSCRIBERS)
  endpoint = each.value
}


# Lambda function
resource "aws_lambda_function" "Lambda-Emailing-SNS" {
  function_name = var.FUNCTION_NAME
  handler = "lambda_function.handler"
  runtime = "python3.8"
  role = aws_iam_role.Lambda-Emailing-Role.arn

  source_code_hash = filebase64sha256("${path.module}/../function/email-service.zip")
  filename = "${path.module}/../function/email-service.zip"
  
  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.new-product-topic.arn
    }
  }
}


# S3 bucket
resource "aws_s3_bucket" "lambda-emailing-service" {
  bucket = var.BUCKET_NAME

  tags = {
    Name        = var.TAG_NAME
    Environment = var.TAG_ENV
  }
}

# bucket notification
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.lambda-emailing-service.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.Lambda-Emailing-SNS.arn
    # Docs: https://docs.aws.amazon.com/AmazonS3/latest/userguide/notification-how-to-event-types-and-destinations.html#supported-notification-event-types
    events = ["s3:ObjectCreated:*"]
    filter_prefix = "email"
    filter_suffix = ".csv"
  }
}