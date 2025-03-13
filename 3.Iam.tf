resource "aws_iam_role" "lambda_role" {
  name = "FacialRekog"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "dynamodb_full_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "rekognition_full_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRekognitionFullAccess"
}

#Otro roll 

# Crear el rol IAM para API Gateway
resource "aws_iam_role" "facerekognition_proj" {
  name = "facerekognition_proj"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "apigateway.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Crear la policy que permite subir objetos a S3
resource "aws_iam_policy" "FaceRekogPolicies" {
  name        = "FaceRekogPolicies"
  description = "Permite a API Gateway subir imágenes al bucket S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "s3:PutObject"
      Resource = "arn:aws:s3:::visitor-images-storage-rk1/*"  # Permitir cualquier objeto en el bucket
    }]
  })
}

# Asociar la policy al rol
resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.facerekognition_proj.name
  policy_arn = aws_iam_policy.FaceRekogPolicies.arn
}

#Full acess lambda
resource "aws_iam_role_policy_attachment" "lambda_full_access" {
  role       = aws_iam_role.facerekognition_proj.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}

# Asociar la policy AmazonAPIGatewayPushToCloudWatchLogs al rol facerekognition_proj
resource "aws_iam_role_policy_attachment" "attach_apigateway_logs" {
  role       = aws_iam_role.facerekognition_proj.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}