# Api Gateway

resource "aws_api_gateway_rest_api" "api" {
  name        = "TerraformDemoApi"
  description = "API for demoing Terraform"
}

resource "aws_api_gateway_deployment" "api_gateway_deployment" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "live"

  depends_on = ["aws_api_gateway_integration.demo_integration"]
}

resource "aws_api_gateway_resource" "demo_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part   = "artists"
}

resource "aws_api_gateway_method" "demo_method" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.demo_resource.id}"
  http_method   = "GET"

  authorization = "NONE"
}

resource "aws_api_gateway_integration" "demo_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.demo_resource.id}"
  http_method = "${aws_api_gateway_method.demo_method.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.greatest_artist_lambda.invoke_arn}"
}

# IAM

resource "aws_iam_role" "assumed_lambda_exec" {
  name = "DemoApiLambdaPolicy"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloud_watch" {
  name = "DemoApiCloudWatchLoggingPolicy"

  role = "${aws_iam_role.assumed_lambda_exec.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

# Lambda

resource "aws_lambda_function" "greatest_artist_lambda" {
  function_name    = "TerraformDemoLambda"
  s3_bucket        = "${aws_s3_bucket.lambda_bucket.id}"
  s3_key           = "${aws_s3_bucket_object.lambda_code.key}"
  role             = "${aws_iam_role.assumed_lambda_exec.arn}"
  handler          = "index.handler"
  runtime          = "nodejs6.10"
}

resource "aws_lambda_permission" "api_gateway_deployment_lambda_allowance" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.greatest_artist_lambda.arn}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_deployment.api_gateway_deployment.execution_arn}/*/*"
}

# S3

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "greatest-artist-terraform-demo-code"
  acl = "public-read"
}

data "archive_file" "lambda_zip" {
    type          = "zip"
    source_file   = "./code/index.js"
    output_path   = "./code/archived.zip"
}

resource "aws_s3_bucket_object" "lambda_code" {
  key = "demo-api-code.zip"
  bucket = "${aws_s3_bucket.lambda_bucket.id}"
  source = "${data.archive_file.lambda_zip.output_path}"
}