# ---------------------------------
# API GATEWAY: Facial Rekognition
# ---------------------------------
resource "aws_api_gateway_rest_api" "facial_rekognition_api" {
  name        = "facial-rekognition-api"
  description = "API para subir imágenes a S3 y autenticar empleados"
  endpoint_configuration {
  types = ["REGIONAL"]
  }

  binary_media_types = [
    "image/jpeg",
    "image/jpg",
    "image/png"
  ]
}

# ---------------------------------
# RECURSO: /bucket/{bucket}/{filename}
# ---------------------------------
resource "aws_api_gateway_resource" "bucket" {
  rest_api_id = aws_api_gateway_rest_api.facial_rekognition_api.id
  parent_id   = aws_api_gateway_rest_api.facial_rekognition_api.root_resource_id
  path_part   = "{bucket}"
}

# ---------------------------
# Options para /bucket
# ---------------------------
resource "aws_api_gateway_method" "options_bucket" {
  rest_api_id   = aws_api_gateway_rest_api.facial_rekognition_api.id
  resource_id   = aws_api_gateway_resource.bucket.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_bucket_integration" {
  rest_api_id   = aws_api_gateway_rest_api.facial_rekognition_api.id
  resource_id   = aws_api_gateway_resource.bucket.id
  http_method   = aws_api_gateway_method.options_bucket.http_method
  type          = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_method_response" "options_bucket_response" {
  rest_api_id = aws_api_gateway_rest_api.facial_rekognition_api.id
  resource_id = aws_api_gateway_resource.bucket.id
  http_method = aws_api_gateway_method.options_bucket.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "options_bucket_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.facial_rekognition_api.id
  resource_id = aws_api_gateway_resource.bucket.id
  http_method = aws_api_gateway_method.options_bucket.http_method
  status_code = aws_api_gateway_method_response.options_bucket_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,PUT'",
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'"
  }
}

#FILENAME
resource "aws_api_gateway_resource" "filename" {
  rest_api_id = aws_api_gateway_rest_api.facial_rekognition_api.id
  parent_id   = aws_api_gateway_resource.bucket.id
  path_part   = "{filename}"
}

resource "aws_api_gateway_method" "put_image" {
  rest_api_id   = aws_api_gateway_rest_api.facial_rekognition_api.id
  resource_id   = aws_api_gateway_resource.filename.id
  http_method   = "PUT"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.bucket"   = true
    "method.request.path.filename" = true
  }
}

resource "aws_api_gateway_integration" "s3_put_object" {
  rest_api_id             = aws_api_gateway_rest_api.facial_rekognition_api.id
  resource_id             = aws_api_gateway_resource.filename.id
  http_method             = aws_api_gateway_method.put_image.http_method
  integration_http_method = "PUT"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:us-east-1:s3:path/{bucket}/{filename}"

  credentials = aws_iam_role.facerekognition_proj.arn

  request_parameters = {
    "integration.request.path.bucket"   = "method.request.path.bucket"
    "integration.request.path.filename" = "method.request.path.filename"
  }
}

resource "aws_api_gateway_method_response" "put_image_response" {
  rest_api_id = aws_api_gateway_rest_api.facial_rekognition_api.id
  resource_id = aws_api_gateway_resource.filename.id
  http_method = aws_api_gateway_method.put_image.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "put_image_integration_response" {
  depends_on  = [aws_api_gateway_integration.s3_put_object]
  rest_api_id = aws_api_gateway_rest_api.facial_rekognition_api.id
  resource_id = aws_api_gateway_resource.filename.id
  http_method = aws_api_gateway_method.put_image.http_method
  status_code = aws_api_gateway_method_response.put_image_response.status_code
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


# ---------------------------
# Options para /bucket/{bucket}/{filename}
# ---------------------------
resource "aws_api_gateway_method" "options_filename" {
  rest_api_id   = aws_api_gateway_rest_api.facial_rekognition_api.id
  resource_id   = aws_api_gateway_resource.filename.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_filename_integration" {
  rest_api_id   = aws_api_gateway_rest_api.facial_rekognition_api.id
  resource_id   = aws_api_gateway_resource.filename.id
  http_method   = aws_api_gateway_method.options_filename.http_method
  type          = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_method_response" "options_filename_response" {
  rest_api_id = aws_api_gateway_rest_api.facial_rekognition_api.id
  resource_id = aws_api_gateway_resource.filename.id
  http_method = aws_api_gateway_method.options_filename.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "options_filename_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.facial_rekognition_api.id
  resource_id = aws_api_gateway_resource.filename.id
  http_method = aws_api_gateway_method.options_filename.http_method
  status_code = aws_api_gateway_method_response.options_filename_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,PUT'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'"
  }
}
# ---------------------------------
# RECURSO: /employee
# ---------------------------------
resource "aws_api_gateway_resource" "employee" {
  rest_api_id = aws_api_gateway_rest_api.facial_rekognition_api.id
  parent_id   = aws_api_gateway_rest_api.facial_rekognition_api.root_resource_id
  path_part   = "employee"
}

resource "aws_api_gateway_method" "employee_get" {
  rest_api_id   = aws_api_gateway_rest_api.facial_rekognition_api.id
  resource_id   = aws_api_gateway_resource.employee.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "employee_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.facial_rekognition_api.id
  resource_id             = aws_api_gateway_resource.employee.id
  http_method             = aws_api_gateway_method.employee_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.employee_authentication.invoke_arn
  credentials             = aws_iam_role.facerekognition_proj.arn  # Se agrega el rol IAM
}

# First, add method response for GET
resource "aws_api_gateway_method_response" "employee_get_response" {
  rest_api_id = aws_api_gateway_rest_api.facial_rekognition_api.id
  resource_id = aws_api_gateway_resource.employee.id
  http_method = aws_api_gateway_method.employee_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
  
  response_models = {
    "application/json" = "Empty"
  }
}

# Then, add integration response for GET
resource "aws_api_gateway_integration_response" "employee_get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.facial_rekognition_api.id
  resource_id = aws_api_gateway_resource.employee.id
  http_method = aws_api_gateway_method.employee_get.http_method
  status_code = aws_api_gateway_method_response.employee_get_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  
  depends_on = [
    aws_api_gateway_integration.employee_lambda
  ]
}


# ---------------------------------
# HABILITAR CORS
# ---------------------------------
resource "aws_api_gateway_method" "options_employee" {
  rest_api_id   = aws_api_gateway_rest_api.facial_rekognition_api.id
  resource_id   = aws_api_gateway_resource.employee.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "employee_options_integration" {
  rest_api_id   = aws_api_gateway_rest_api.facial_rekognition_api.id
  resource_id   = aws_api_gateway_resource.employee.id
  http_method   = aws_api_gateway_method.options_employee.http_method
  type          = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_method_response" "options_response_employee" {
  rest_api_id = aws_api_gateway_rest_api.facial_rekognition_api.id
  resource_id = aws_api_gateway_resource.employee.id
  http_method = aws_api_gateway_method.options_employee.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "options_integration_response_employee" {
  rest_api_id = aws_api_gateway_rest_api.facial_rekognition_api.id
  resource_id = aws_api_gateway_resource.employee.id
  http_method = aws_api_gateway_method.options_employee.http_method
  status_code = aws_api_gateway_method_response.options_response_employee.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'"
  }
}


# Add permission for API Gateway to invoke the Lambda function
resource "aws_lambda_permission" "api_gateway_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.employee_authentication.function_name
  principal     = "apigateway.amazonaws.com"
  
  # The source ARN restricts which API Gateway can invoke the Lambda
  # Format: arn:aws:execute-api:{region}:{account_id}:{api_id}/*/{http_method}/{resource_path}
  source_arn = "${aws_api_gateway_rest_api.facial_rekognition_api.execution_arn}/*/${aws_api_gateway_method.employee_get.http_method}${aws_api_gateway_resource.employee.path}"
}


# ---------------------------------
# DEPLOY API - STAGE "DEV"
# ---------------------------------
resource "aws_api_gateway_deployment" "dev_deployment" {
  depends_on = [
    aws_api_gateway_integration.s3_put_object,
    aws_api_gateway_integration.employee_lambda,
    aws_api_gateway_integration_response.put_image_integration_response,
    aws_api_gateway_integration_response.employee_get_integration_response,
    aws_api_gateway_integration_response.options_integration_response_employee,
    aws_api_gateway_integration_response.options_filename_integration_response,
    aws_api_gateway_integration_response.options_bucket_integration_response
  ]

  rest_api_id = aws_api_gateway_rest_api.facial_rekognition_api.id
  stage_name  = "DEV"
}
  