resource "aws_ecr_repository" "repo" {
  name = "fon-automatizacija"

  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

  force_delete = true
}


module "ecs_cluster" {
  source       = "terraform-aws-modules/ecs/aws//modules/cluster"
  cluster_name = "fon-automatizacija-cluster"

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
        base   = 20
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

}

resource "aws_security_group" "ecs_public_sg" {
  name   = "ecs-public-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = "fon-automatizacija"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "2048"
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "fon-automatizacija-container"
      image     = "${aws_ecr_repository.repo.repository_url}:latest"
      cpu       = 1024
      memory    = 2048
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_app.name
          awslogs-region        = "eu-central-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}


resource "aws_cloudwatch_log_group" "ecs_app" {
  name = "/ecs/fon-automatizacija"
}

module "ecs_service" {
  source      = "terraform-aws-modules/ecs/aws//modules/service"
  name        = "fon-automatizacija-service"
  cluster_arn = module.ecs_cluster.arn

  cpu    = 1024
  memory = 2048

  subnet_ids             = module.vpc.public_subnets
  assign_public_ip       = true
  security_group_ids     = [aws_security_group.ecs_public_sg.id]
  task_definition_arn    = aws_ecs_task_definition.main.arn
  create_task_definition = false

  desired_count = 1
}