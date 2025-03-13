resource "aws_lambda_function" "employee_authentication" {
  function_name    = "employee-authentication"
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.12"
  handler          = "employee_authen.lambda_handler"
  architectures    = ["x86_64"]

  memory_size      = 500
  timeout          = 60

  s3_bucket        = aws_s3_bucket.lambda_code_bucket.bucket
  s3_key           = "employee_authentication.zip"
}