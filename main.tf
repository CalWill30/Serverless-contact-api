terraform {
  required_providers {
    aws     = { source = "hashicorp/aws", version = "~> 5.0" }
    archive = { source = "hashicorp/archive", version = "~> 2.4" }
  }
}

provider "aws" {
  region = "us-east-1"
}


resource "aws_dynamodb_table" "contacts" {
  name         = "contacts"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}


resource "aws_iam_role" "lambda_role" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Principal = { Service = "lambda.amazonaws.com" },
      Effect    = "Allow"
    }]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_basic_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


data "archive_file" "contact_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/app.py"
  output_path = "${path.module}/build/contact.zip"
}


resource "aws_lambda_function" "contact_handler" {
  function_name    = "serverless-contact-api"
  role             = aws_iam_role.lambda_role.arn
  handler          = "app.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.contact_zip.output_path
  source_code_hash = data.archive_file.contact_zip.output_base64sha256

  environment {
    variables = { TABLE_NAME = aws_dynamodb_table.contacts.name }
  }
}


resource "aws_apigatewayv2_api" "contact_api" {
  name          = "contact-api"
  protocol_type = "HTTP"
}


resource "aws_apigatewayv2_integration" "contact_integration" {
  api_id                 = aws_apigatewayv2_api.contact_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.contact_handler.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}


resource "aws_apigatewayv2_route" "contact_route" {
  api_id    = aws_apigatewayv2_api.contact_api.id
  route_key = "POST /contact"
  target    = "integrations/${aws_apigatewayv2_integration.contact_integration.id}"
}


resource "aws_apigatewayv2_stage" "contact_stage" {
  api_id      = aws_apigatewayv2_api.contact_api.id
  name        = "$default"
  auto_deploy = true
}


resource "aws_lambda_permission" "allow_api_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.contact_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.contact_api.execution_arn}/*/*"
}

output "invoke_url" {
  value = aws_apigatewayv2_api.contact_api.api_endpoint
}
