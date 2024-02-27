terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

variable "SECRET_KEY_BASE" {
  type = string
}

resource "aws_sqs_queue" "rails-lambda-worker" {
  name                      = "rails-lambda-worker"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
}

resource "aws_ecr_repository" "rails-lambda-worker" {
  name                 = "rails-lambda-worker"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_execution_role_attachment" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

resource "aws_lambda_function" "rails-lambda-worker" {
  package_type  = "Image"
  image_uri     = "919206211910.dkr.ecr.us-east-1.amazonaws.com/rails-lambda-worker:14"
  function_name = "rails-lambda-worker"
  role          = aws_iam_role.iam_for_lambda.arn
  timeout       = 60

  environment {
    variables = {
      SECRET_KEY_BASE = var.SECRET_KEY_BASE
    }
  }
}

resource "aws_lambda_event_source_mapping" "rails-lambda-worker" {
  event_source_arn = aws_sqs_queue.rails-lambda-worker.arn
  function_name    = aws_lambda_function.rails-lambda-worker.arn
}
