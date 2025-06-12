# provider "aws" {
#   region = "eu-west-2"
# }


# ##########################
# # Data Sources
# ##########################
# data "aws_availability_zones" "available" {}


# data "aws_route53_zone" "primary" {
#   name         = "yonishage.co.uk."
#   private_zone = false
# }


# ##########################
# # VPC and Networking
# ##########################
# resource "aws_vpc" "main" {
#   cidr_block           = "10.0.0.0/16"
#   enable_dns_support   = true
#   enable_dns_hostnames = true


#   tags = {
#     Name = "threatopsecs-vpc"
#   }
# }


# resource "aws_subnet" "public" {
#   count                   = 2
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
#   availability_zone       = data.aws_availability_zones.available.names[count.index]
#   map_public_ip_on_launch = true


#   tags = {
#     Name = "threatopsecs-public-${count.index}"
#     Tier = "public"
#   }
# }


# resource "aws_subnet" "private" {
#   count             = 2
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 2)
#   availability_zone = data.aws_availability_zones.available.names[count.index]


#   tags = {
#     Name = "threatopsecs-private-${count.index}"
#     Tier = "private"
#   }
# }


# resource "aws_internet_gateway" "igw" {
#   vpc_id = aws_vpc.main.id


#   tags = {
#     Name = "threatopsecs-igw"
#   }
# }


# resource "aws_eip" "nat" {
#   count = 1
#   vpc   = true
# }


# resource "aws_nat_gateway" "nat" {
#   allocation_id = aws_eip.nat[0].id
#   subnet_id     = aws_subnet.public[0].id


#   tags = {
#     Name = "threatopsecs-nat"
#   }
# }


# resource "aws_route_table" "public" {
#   vpc_id = aws_vpc.main.id


#   tags = {
#     Name = "threatopsecs-public-rt"
#   }
# }


# resource "aws_route" "public_internet_access" {
#   route_table_id         = aws_route_table.public.id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = aws_internet_gateway.igw.id
# }


# resource "aws_route_table_association" "public_assoc" {
#   count          = 2
#   subnet_id      = aws_subnet.public[count.index].id
#   route_table_id = aws_route_table.public.id
# }


# resource "aws_route_table" "private" {
#   vpc_id = aws_vpc.main.id


#   tags = {
#     Name = "threatopsecs-private-rt"
#   }
# }


# resource "aws_route" "private_nat_route" {
#   route_table_id         = aws_route_table.private.id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = aws_nat_gateway.nat.id
# }


# resource "aws_route_table_association" "private_assoc" {
#   count          = 2
#   subnet_id      = aws_subnet.private[count.index].id
#   route_table_id = aws_route_table.private.id
# }


# ##########################
# # Security Groups
# ##########################
# resource "aws_security_group" "alb" {
#   name        = "threatopsecs-alb-sg"
#   description = "Allow inbound HTTP and HTTPS"
#   vpc_id      = aws_vpc.main.id


#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }


#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }


#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }


# resource "aws_security_group" "ecs_tasks" {
#   name   = "threatopsecs-ecs-tasks"
#   vpc_id = aws_vpc.main.id


#   ingress {
#     from_port       = 3000
#     to_port         = 3000
#     protocol        = "tcp"
#     security_groups = [aws_security_group.alb.id]
#   }


#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }


# ##########################
# # ACM and DNS
# ##########################
# resource "aws_acm_certificate" "cert" {
#   domain_name       = "tm.echo.yonishage.co.uk"
#   validation_method = "DNS"


#   lifecycle {
#     create_before_destroy = true
#   }
# }


# resource "aws_route53_record" "cert_validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
#       name  = dvo.resource_record_name
#       type  = dvo.resource_record_type
#       value = dvo.resource_record_value
#     }
#   }


#   zone_id = data.aws_route53_zone.primary.zone_id
#   name    = each.value.name
#   type    = each.value.type
#   ttl     = 60
#   records = [each.value.value]
# }


# resource "aws_acm_certificate_validation" "cert_validation" {
#   certificate_arn         = aws_acm_certificate.cert.arn
#   validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
# }


# resource "aws_route53_record" "app" {
#   zone_id = data.aws_route53_zone.primary.zone_id
#   name    = "tm.echo.yonishage.co.uk"
#   type    = "A"


#   alias {
#     name                   = aws_lb.app_alb.dns_name
#     zone_id                = aws_lb.app_alb.zone_id
#     evaluate_target_health = true
#   }
# }


# ##########################
# # ALB
# ##########################
# resource "aws_lb" "app_alb" {
#   name               = "threatopsecs-alb"
#   internal           = false
#   load_balancer_type = "application"
#   subnets            = aws_subnet.public[*].id
#   security_groups    = [aws_security_group.alb.id]
# }


# resource "aws_lb_target_group" "app_tg" {
#   name        = "threatopsecs-tg"
#   port        = 3000
#   protocol    = "HTTP"
#   vpc_id      = aws_vpc.main.id
#   target_type = "ip"


#   health_check {
#     path                = "/health"
#     interval            = 30
#     timeout             = 5
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#   }
# }


# resource "aws_lb_listener" "http" {
#   load_balancer_arn = aws_lb.app_alb.arn
#   port              = 80
#   protocol          = "HTTP"


#   default_action {
#     type = "redirect"
#     redirect {
#       protocol    = "HTTPS"
#       port        = "443"
#       status_code = "HTTP_301"
#     }
#   }
# }


# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.app_alb.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = aws_acm_certificate_validation.cert_validation.certificate_arn


#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.app_tg.arn
#   }
# }


# ##########################
# # ECS
# ##########################
# resource "aws_ecs_cluster" "main" {
#   name = "threatopsecs-cluster"
# }


# resource "aws_iam_role" "ecs_task_execution_role" {
#   name = "threatopsecs-ecs-task-execution-role"


#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Effect = "Allow",
#       Principal = { Service = "ecs-tasks.amazonaws.com" },
#       Action    = "sts:AssumeRole"
#     }]
#   })
# }


# resource "aws_iam_role_policy_attachment" "ecs_task_exec_attach" {
#   role       = aws_iam_role.ecs_task_execution_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }


# resource "aws_cloudwatch_log_group" "ecs" {
#   name              = "/ecs/threatopsecs"
#   retention_in_days = 7
# }


# resource "aws_ecs_task_definition" "app" {
#   family                   = "threatopsecs-task"
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   cpu                      = "256"
#   memory                   = "512"
#   execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn


#   container_definitions = jsonencode([{
#     name      = "app-container"
#     image     = "376129873306.dkr.ecr.eu-west-2.amazonaws.com/threatops:latest"
#     essential = true
#     portMappings = [{
#       containerPort = 3000
#       protocol      = "tcp"
#     }]
#     logConfiguration = {
#       logDriver = "awslogs",
#       options = {
#         awslogs-group         = "/ecs/threatopsecs",
#         awslogs-region        = "eu-west-2",
#         awslogs-stream-prefix = "app"
#       }
#     },
#     healthCheck = {
#       command     = ["CMD-SHELL", "curl -f http://localhost:3000/health || exit 1"],
#       interval    = 30,
#       timeout     = 5,
#       retries     = 3,
#       startPeriod = 10
#     }
#   }])
# }


# resource "aws_ecs_service" "app" {
#   name            = "threatopsecs-service"
#   cluster         = aws_ecs_cluster.main.id
#   task_definition = aws_ecs_task_definition.app.arn
#   desired_count   = 1
#   launch_type     = "FARGATE"


#   network_configuration {
#     subnets         = aws_subnet.private[*].id
#     security_groups = [aws_security_group.ecs_tasks.id]
#     assign_public_ip = false
#   }


#   load_balancer {
#     target_group_arn = aws_lb_target_group.app_tg.arn
#     container_name   = "app-container"
#     container_port   = 3000
#   }


#   depends_on = [aws_lb_listener.https]
# }
provider "aws" {
 region = "eu-west-2"
}


########################################
# 1) VPC
########################################
module "vpc" {
 source   = "./modules/vpc"
 name     = "test"
 vpc_cidr = "10.0.0.0/16"
}


########################################
# 2) ACM Certificate for HTTPS
########################################
resource "aws_acm_certificate" "test_cert" {
 domain_name       = "tm.yonishage.co.uk"
 validation_method = "DNS"


 lifecycle {
   create_before_destroy = true
 }
}


data "aws_route53_zone" "primary" {
 name         = "tm.yonishage.co.uk"
 private_zone = false
}


resource "aws_route53_record" "cert_validation" {
 for_each = {
   for dvo in aws_acm_certificate.test_cert.domain_validation_options : dvo.domain_name => {
     name  = dvo.resource_record_name
     type  = dvo.resource_record_type
     value = dvo.resource_record_value
   }
 }


 zone_id = data.aws_route53_zone.primary.zone_id
 name    = each.value.name
 type    = each.value.type
 ttl     = 300
 records = [each.value.value]
}


resource "aws_acm_certificate_validation" "test_validation" {
 certificate_arn         = aws_acm_certificate.test_cert.arn
 validation_record_fqdns = [for rec in aws_route53_record.cert_validation : rec.fqdn]
}


########################################
# 3) ALB
########################################
module "alb" {
  source              = "./modules/alb"
  name_prefix         = "test"
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnets
  certificate_arn     = aws_acm_certificate_validation.test_validation.certificate_arn
}

resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "tm.yonishage.co.uk"
  type    = "A"

  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
}

module "ecs" {
  source                = "./modules/ecs"
  name_prefix           = "test"
  image                 = "376129873306.dkr.ecr.eu-west-2.amazonaws.com/threatops:latest"
  container_port        = 3000
  subnet_ids            = module.vpc.private_subnets
  security_group_ids    = [module.alb.security_group_id]
  desired_count         = 1
  cpu                   = 256
  memory                = 512
  aws_region            = "eu-west-2"
  target_group_arn      = module.alb.target_group_arn
  vpc_id                = module.vpc.vpc_id
  alb_security_group_id = module.alb.security_group_id
}
