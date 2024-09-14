terraform {
  backend "s3" {
    bucket = "food-cloud-terraform-remote-state"
    key    = "development/backend.tfstate"
    # region = var.aws_region
    # Variables doesn't work here :(
    region = "us-east-1"
  }
}
