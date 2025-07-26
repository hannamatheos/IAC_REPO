resource "aws_s3_bucket" "s3_service_bucket" {
  bucket = "${var.owner}-s3-service-bucket"
}

resource "aws_sqs_queue" "sqs_service_queue" {
  name = "${var.owner}-sqs-service"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}


data "aws_vpc" "hanna_vpc" {
  tags = {
    Name = var.vpc_name
  }
}

# data "aws_subnets" "hanna_public" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.hanna_vpc.id]
#   }
#   filter {
#     name   = "tag:Name"
#     values = ["*public*"] # Matches names like "hanna-vpc-public-ap-southeast-1a"
#   }
# }
#

data "aws_subnets" "hanna_public_ids" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.hanna_vpc.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*public*"] # Matches names like "hanna-vpc-public-ap-southeast-1a"
  }
}