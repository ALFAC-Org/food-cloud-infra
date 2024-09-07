resource "aws_vpc" "food_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "food_vpc"
  }
}

resource "aws_subnet" "food_private_subnet" {
  vpc_id            = aws_vpc.food_vpc.id
  cidr_block        = var.subnet_private_cidr_block
  availability_zone = var.subnet_availability_zone_az_1

  tags = {
    Name = "food_private_subnet"
  }
}

resource "aws_subnet" "food_public_subnet" {
  vpc_id            = aws_vpc.food_vpc.id
  cidr_block        = var.subnet_public_cidr_block
  availability_zone = var.subnet_availability_zone_az_1

  tags = {
    Name = "food_public_subnet"
  }
}

resource "aws_subnet" "food_database_subnet_az_1" {
  vpc_id            = aws_vpc.food_vpc.id
  cidr_block        = var.subnet_database_1_cidr_block
  availability_zone = var.subnet_availability_zone_az_1

  tags = {
    Name = "food_database_subnet_az_1"
  }
}

resource "aws_subnet" "food_database_subnet_az_2" {
  vpc_id            = aws_vpc.food_vpc.id
  cidr_block        = var.subnet_database_2_cidr_block
  availability_zone = var.subnet_availability_zone_az_2

  tags = {
    Name = "food_database_subnet_az_1"
  }
}