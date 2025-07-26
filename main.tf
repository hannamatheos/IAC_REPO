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

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 5.9.0"

  cluster_name = "${var.owner}-multiservices-ecs"

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }

  services = {
    HANNA-S3-SERVICE= {

      cpu = 512
      memory = 1024

      container_definitions = {

          essential = true

          image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.id}.amazonaws.com/${var.owner}-s3-service-ecr:latest"

          port_mappings = [
            {
              containerPort = 8080
              protocol      = "tcp"
            }
          ]
          environment = [
            {
              name = "AWS_REGION"
              value = "ap-southeast-1"

            },
            {
              name = "BUCKET_NAME"
              value = "${var.owner}-s3-service-bucket"
            }
          ]
        }
      

      assign_public_ip = true
      deployment_minimum_healthy_percent = 100
      subnet_ids= flatten(data.aws_subnets.hanna_public_ids.ids)
      security_group_ids= [module.s3_service_sg.security_group_id]
      create_tasks_iam_role              = false
      tasks_iam_role_arn                 = module.s3_service_task_role.iam_role_arn
   
      

    }
  
  hanna-sqs-service = {
        cpu    = 512
        memory = 1024
        container_definitions = {
          hanna-sqs-service-container = {
            essential = true
            image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.id}.amazonaws.com/${var.owner}-sqs-service-ecr:latest"
            port_mappings = [
              {
                containerPort = 5002
                protocol      = "tcp"
              }
            ]
            environment = [
              {
                name  = "AWS_REGION"
                value = "ap-southeast-1"
              },
              {
                name  = "QUEUE_URL"
                value = "${var.owner}-sqs-service-queue"
              }
            ]
          }
        }
        assign_public_ip                   = true
        deployment_minimum_healthy_percent = 100
        subnet_ids= flatten(data.aws_subnets.hanna_public_ids.ids)
        security_group_ids                 = [module.sqs_service_sg.security_group_id]
        create_tasks_iam_role              = false
        tasks_iam_role_arn                 = module.sqs_service_task_role.iam_role_arn
      }
    }

}
