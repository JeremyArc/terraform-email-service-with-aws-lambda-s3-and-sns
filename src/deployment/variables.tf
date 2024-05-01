variable "REGION" {
  type = string
  default = "ap-southeast-1"
}

# Lambda
variable "FUNCTION_NAME" {
    type = string
    default = "Lambda-Emailing-SNS"
}

# SNS
variable "TOPIC_NAME" {
  type = string
  default = "new-product-topic"
  
}

variable "SUBSCRIBERS" {
  type = list(string)
  default = [ "jessada.srm@gmail.com", "test@gmail.com" ]
}

# S3 bucket
variable "BUCKET_NAME" {
    type = string
    default = "lambda-emailing-service"
}
variable "TAG_NAME" {
    type = string
    default = "lambda-emailing-service"
}

variable "TAG_ENV" {
  type = string
  default = "dev"
}

