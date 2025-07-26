module "s3_service_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1.0"

  name        = "${var.owner}-s3-service-ecs-sg"
  description = "Security group for s3 service"
  vpc_id      = data.aws_vpc.hanna_vpc.id

  ingress_with_cidr_blocks = [
    {
      from_port   = 5001
      to_port     = 5001
      protocol    = "tcp"
      description = "S3 Service Inbound"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  egress_rules = ["all-all"]
}

module "sqs_service_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1.0"

  name        = "${var.owner}-sqs-service-ecs-sg"
  description = "Security group for sqs service"
  vpc_id      = data.aws_vpc.hanna_vpc.id

  ingress_with_cidr_blocks = [
    {
      from_port   = 5002
      to_port     = 5002
      protocol    = "tcp"
      description = "SQS Service Inbound"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  egress_rules = ["all-all"]
}