# Crear la función Lambda
resource "aws_lambda_function" "employee_registration" {
  function_name    = "employee-registration"
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.12"
  handler          = "employee_regis.lambda_handler" 
  architectures    = ["x86_64"]

  memory_size      = 500
  timeout          = 60

  s3_bucket        = aws_s3_bucket.lambda_code_bucket.bucket
  s3_key           = aws_s3_object.lambda_code.key

  # Hash del archivo ZIP para detectar cambios
  source_code_hash = filebase64sha256("employee_regis.zip")
}

# Permitir que S3 invoque la función Lambda
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.employee_registration.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.employee_images_rk1.arn
}

# Crear un trigger de S3 para la función Lambda
resource "aws_s3_bucket_notification" "employee_images_trigger" {
  bucket = aws_s3_bucket.employee_images_rk1.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.employee_registration.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3_invoke]
}