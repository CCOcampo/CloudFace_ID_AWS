resource "aws_dynamodb_table" "employee" {
  name         = "employee"
  billing_mode = "PAY_PER_REQUEST"  # Modo bajo demanda

  attribute {
    name = "rekognitionId"
    type = "S"  # String
  }

  hash_key = "rekognitionId"  # Partition Key
}