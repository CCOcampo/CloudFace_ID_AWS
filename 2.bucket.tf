# Crear el bucket para imágenes de empleados
resource "aws_s3_bucket" "employee_images_rk1" {
  bucket = "employee-images-rk1"
}

resource "aws_s3_bucket_versioning" "employee_images_rk1_versioning" {
  bucket = aws_s3_bucket.employee_images_rk1.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Crear el bucket para imágenes de visitantes
resource "aws_s3_bucket" "visitor_images_storage_rk1" {
  bucket = "visitor-images-storage-rk1"
}

resource "aws_s3_bucket_versioning" "visitor_images_storage_rk1_versioning" {
  bucket = aws_s3_bucket.visitor_images_storage_rk1.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Crear el bucket para almacenar el código de la función Lambda
resource "aws_s3_bucket" "lambda_code_bucket" {
  bucket = "lambda-code-bucket-employeeres"
}

# Subir el código de la función employee_registration a S3
resource "aws_s3_object" "lambda_code" {
  bucket = aws_s3_bucket.lambda_code_bucket.bucket
  key    = "employee_registration.zip"
  source = "/Users/cristhiancamiloocampo/Documents/Proyecto_Data/Git/CloudFace_ID_AWS/employee_regis.zip"
  etag   = filemd5("/Users/cristhiancamiloocampo/Documents/Proyecto_Data/Git/CloudFace_ID_AWS/employee_regis.zip")

  depends_on = [aws_s3_bucket.lambda_code_bucket]
}

# Subir el código de la función employee_authentication a S3
resource "aws_s3_object" "lambda_code_employee_authentication" {
  bucket = aws_s3_bucket.lambda_code_bucket.bucket
  key    = "employee_authentication.zip"
  source = "/Users/cristhiancamiloocampo/Documents/Proyecto_Data/Git/CloudFace_ID_AWS/employee_authen.zip"
  etag   = filemd5("/Users/cristhiancamiloocampo/Documents/Proyecto_Data/Git/CloudFace_ID_AWS/employee_authen.zip")

  depends_on = [aws_s3_bucket.lambda_code_bucket]
}