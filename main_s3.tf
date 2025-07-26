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
  

      hanna-s3-service = {
        cpu    = 512
        memory = 1024
        container_definitions = {
          hanna-s3-service-container = {
            essential = true
            image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.id}.amazonaws.com/${var.owner}-s3-service-ecr:latest"
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
                value = "${var.owner}-s3-service-queue"
              }
            ]
          }
        }
        assign_public_ip                   = true
        deployment_minimum_healthy_percent = 100
        subnet_ids                         = flatten(data.aws_subnets.hanna_public_ids.ids)
        security_group_ids                 = [module.s3_service_sg.security_group_id]
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
        subnet_ids                         = flatten(data.aws_subnets.hanna_public_ids.ids)
        security_group_ids                 = [module.sqs_service_sg.security_group_id]
        create_tasks_iam_role              = false
        tasks_iam_role_arn                 = module.sqs_service_task_role.iam_role_arn
      }
    }
  }