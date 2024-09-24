terraform {
  backend "s3" {
    bucket = var.aws_bucket_name
    key    = "development/backend.tfstate"
    # region = var.aws_region
    # Variables doesn't work here :(
    region = var.region
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