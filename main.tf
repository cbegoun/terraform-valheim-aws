# Terraform: Main Infrastructure Setup

# VPC Configuration
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

# Security Group for Valheim Server
resource "aws_security_group" "valheim_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 2456
    to_port     = 2458
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Route 53 Hosted Zone
resource "aws_route53_zone" "main" {
  name = "raeon.tech"
}

# Enable Route 53 Query Logging
resource "aws_cloudwatch_log_group" "route53_query_logs" {
  name = "route53-query-logs"
}

resource "aws_route53_query_log" "valheim_query_logging" {
  zone_id   = aws_route53_zone.main.id
  log_group_arn = aws_cloudwatch_log_group.route53_query_logs.arn
}

# Route 53 Record for Valheim Server
resource "aws_route53_record" "valheim" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "valheim.raeon.tech"
  type    = "A"
  ttl     = 300
  records = [aws_eip.valheim.public_ip]
}

# ECS Cluster for Valheim Server
resource "aws_ecs_cluster" "valheim" {
  name = "valheim-cluster"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "valheim" {
  family                   = "valheim-server"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([
    {
      name      = "valheim"
      image     = "lloesche/valheim-server"
      essential = true
      portMappings = [
        {
          containerPort = 2456
          hostPort      = 2456
          protocol      = "udp"
        },
        {
          containerPort = 2457
          hostPort      = 2457
          protocol      = "udp"
        },
        {
          containerPort = 2458
          hostPort      = 2458
          protocol      = "udp"
        }
      ]
    }
  ])
}

# ECS Service for Valheim
resource "aws_ecs_service" "valheim" {
  name            = "valheim-service"
  cluster         = aws_ecs_cluster.valheim.id
  task_definition = aws_ecs_task_definition.valheim.arn
  desired_count   = 0
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.main.id]
    security_groups = [aws_security_group.valheim_sg.id]
  }
}

# IAM Role for ECS Execution
resource "aws_iam_role" "ecs_execution" {
  name = "ecs_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy_attachment" "ecs_execution" {
  name       = "ecs_execution"
  roles      = [aws_iam_role.ecs_execution.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Lambda Function to Start Valheim Server
resource "aws_lambda_function" "start_valheim" {
  function_name = "start_valheim"
  role          = aws_iam_role.lambda_execution.arn
  runtime       = "python3.8"
  handler       = "index.lambda_handler"

  source_code_hash = filebase64sha256("lambda_start.py")

  filename = "lambda_start.zip"

  environment {
    variables = {
      CLUSTER_NAME = aws_ecs_cluster.valheim.name
      SERVICE_NAME = aws_ecs_service.valheim.name
    }
  }

  inline_code = <<EOT
import boto3
import os

def lambda_handler(event, context):
    client = boto3.client('ecs')
    response = client.update_service(
        cluster=os.environ['CLUSTER_NAME'],
        service=os.environ['SERVICE_NAME'],
        desiredCount=1
    )
    return response
EOT
}

# Lambda Function to Stop Valheim Server
resource "aws_lambda_function" "stop_valheim" {
  function_name = "stop_valheim"
  role          = aws_iam_role.lambda_execution.arn
  runtime       = "python3.8"
  handler       = "index.lambda_handler"

  source_code_hash = filebase64sha256("lambda_stop.py")

  filename = "lambda_stop.zip"

  environment {
    variables = {
      CLUSTER_NAME = aws_ecs_cluster.valheim.name
      SERVICE_NAME = aws_ecs_service.valheim.name
    }
  }

  inline_code = <<EOT
import boto3
import os

def lambda_handler(event, context):
    client = boto3.client('ecs')
    response = client.update_service(
        cluster=os.environ['CLUSTER_NAME'],
        service=os.environ['SERVICE_NAME'],
        desiredCount=0
    )
    return response
EOT
}
