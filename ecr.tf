resource "aws_ecr_repository" "s3_service" {
  name         = "${var.owner}-s3-service-ecr"
  force_delete = true
}

resource "aws_ecr_repository" "sqs_service" {
  name         = "${var.owner}-sqs-service-ecr"
  force_delete = true
}


