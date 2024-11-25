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

resource "aws_sqs_queue" "image_queue" {
  name = "44-image-generation-queue"
}

resource "aws_lambda_function" "sqs_lambda" {
  filename         = "lambda_code.zip"
  function_name    = "sqs-image-processor"
  role             =  aws_iam_role.lambda_exec.arn
  handler          = "lambda_sqs.lambda_handler"
  runtime          = "python3.9"
  timeout          = 15 # Justerbar Timeout
  environment {
    variables = {
      BUCKET_NAME = "pgr301-couch-explorers"
      CANDIDATE_NUMBER = "44"
    }
  }
  source_code_hash = filebase64sha256("lambda_code.zip")
}

resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = aws_sqs_queue.image_queue.arn
  function_name    = aws_lambda_function.sqs_lambda.arn
  batch_size       = 10
}

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

# Genererer en tilfeldig ID som suffiks for policy-navnet
resource "random_id" "policy_suffix" {
  byte_length = 4
}

# Oppdatering av IAM-policyen med et unikt navn
resource "aws_iam_policy" "lambda_sqs_policy" {
  name        = "lambda_sqs_policy-${random_id.policy_suffix.hex}"  # Bruker tilfeldig ID som suffiks
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