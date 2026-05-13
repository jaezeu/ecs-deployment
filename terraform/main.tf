locals {
  name_prefix     = split("/", "${data.aws_caller_identity.current.arn}")[1]
  resource_prefix = "${local.name_prefix}-ecs-demo"
}

resource "aws_ecr_repository" "ecr" {
  name         = "${local.resource_prefix}-ecr"
  force_delete = true
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 7.5.0"

  cluster_name = local.resource_prefix
  cluster_capacity_providers = ["FARGATE"]

  services = {
    "${local.resource_prefix}-svc" = { #task def and service name
      cpu    = 512
      memory = 1024
      # Container definition(s)
      container_definitions = {
        "${local.resource_prefix}-container" = { #container name
          essential = true
          image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.region}.amazonaws.com/${local.resource_prefix}-ecr:latest"
          port_mappings = [
            {
              containerPort = 8080
              protocol      = "tcp"
            }
          ]
        }
      }
      assign_public_ip                   = true
      deployment_minimum_healthy_percent = 100
      subnet_ids                         = flatten(data.aws_subnets.public.ids)
      security_group_ids                 = [module.ecs_sg.security_group_id]
    }
  }
}

module "ecs_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3.1"

  name        = "${local.resource_prefix}-sg"
  description = "Security group for ecs"
  vpc_id      = data.aws_vpc.default.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-8080-tcp"]
  egress_rules        = ["all-all"]
}
