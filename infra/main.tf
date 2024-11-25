terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.74.0"
    }
  }

  backend "s3" {
    bucket         = "pgr301-2024-terraform-state"
    key            = "44/terraform/lambda_sqs.tfstate"
    region         = "eu-west-1"
    encrypt        = true
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

# SQS Queue for image processing
resource "aws_sqs_queue" "image_queue" {
  name = "44-image-generation-queue"
}

# Lambda function for processing images from SQS
resource "aws_lambda_function" "sqs_lambda" {
  filename         = "lambda_code.zip"
  function_name    = "44-sqs-image-processor"
  role             =  aws_iam_role.lambda_exec.arn
  handler          = "lambda_sqs.lambda_handler"
  runtime          = "python3.9"
  timeout          = 15
  environment {
    variables = {
      BUCKET_NAME = "pgr301-couch-explorers"
      CANDIDATE_NUMBER = "44"
    }
  }
  source_code_hash = filebase64sha256("lambda_code.zip")
}

# Lambda event source mapping for SQS trigger
resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = aws_sqs_queue.image_queue.arn
  function_name    = aws_lambda_function.sqs_lambda.arn
  batch_size       = 10
}

# IAM role for Lambda execution
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role_candidate_44"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Random ID for IAM policy suffix
resource "random_id" "policy_suffix" {
  byte_length = 4
}

# Lambda permissions for SQS and S3 access
resource "aws_iam_policy" "lambda_sqs_policy" {
  name        = "lambda_sqs_policy-${random_id.policy_suffix.hex}"
  description = "Permissions for Lambda to access SQS and S3"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Effect   = "Allow"
        Resource = aws_sqs_queue.image_queue.arn
      },
      {
        Action = [
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::pgr301-couch-explorers/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_sqs_policy.arn
}

# SNS Topic for CloudWatch Alarm notifications
resource "aws_sns_topic" "sqs_alarm_topic" {
  name = "sqs-alarm-topic"
}

# SNS subscription for email alerts
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.sqs_alarm_topic.arn
  protocol  = "email"
  endpoint  = var.alert_email  # Set the email address here
}

# CloudWatch Alarm for ApproximateAgeOfOldestMessage
resource "aws_cloudwatch_metric_alarm" "sqs_message_age_alarm" {
  alarm_name          = "44-sqs-message-age-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 300  # 5 minutes
  alarm_description   = "Triggered if ApproximateAgeOfOldestMessage exceeds threshold"
  dimensions = {
    QueueName = aws_sqs_queue.image_queue.name
  }
  alarm_actions = [
    aws_sns_topic.sqs_alarm_topic.arn
  ]
}

# Variable for the alert email
variable "alert_email" {
  description = "E-postadresse som skal motta alarmvarsler"
  type        = string
}