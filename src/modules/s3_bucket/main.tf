resource "aws_s3_bucket" "lambda-emailing-service" {
  bucket = "lambda-emailing-service"

  tags = {
    Name        = "lambda-emailing-service"
    Environment = "Prod"
  }
}

