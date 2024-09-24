terraform {
  backend "s3" {
    bucket = "food-cloud-terraform-remote-state-copy"
    key    = "development/backend.tfstate"
    # region = var.aws_region
    # Variables doesn't work here :(
    region = "us-east-1"
  }
}

resource "aws_s3_bucket" "lambdas" {
  bucket = var.bucket_food_lambdas
}

resource "aws_s3_object" "valida_cpf_usuario" {
  bucket = aws_s3_bucket.lambdas.bucket
  key    = "valida_cpf_usuario.zip"
  source = "${path.module}/valida_cpf_usuario.zip"
}