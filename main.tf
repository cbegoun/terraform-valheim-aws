terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "valheim_backup" {
  bucket = "backup-valheim.${var.domain_name}"
}

resource "aws_s3_bucket_lifecycle_configuration" "valheim_backup_lifecycle" {
  bucket = aws_s3_bucket.valheim_backup.id

  rule {
    id     = "delete-old-backups"
    status = "Enabled"

    expiration {
      days = 7
    }
  }
}

resource "aws_vpc" "valheim_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "valheim_subnet" {
  vpc_id                  = aws_vpc.valheim_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "valheim_sg" {
  vpc_id = aws_vpc.valheim_vpc.id

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

resource "aws_ecs_cluster" "valheim_cluster" {
  name = "valheim-cluster"
}

resource "aws_ecs_task_definition" "valheim_task" {
  family                   = "valheim-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"

  container_definitions = jsonencode([
    {
      name      = "valheim"
      image     = "lloesche/valheim-server"
      cpu       = 1024
      memory    = 2048
      essential = true
      environment = [
        { name = "SERVER_NAME", value = "MyValheimServer" },
        { name = "WORLD_NAME", value = "MyWorld" },
        { name = "SERVER_PASS", value = "MyPassword" }
      ]
      portMappings = [
        { containerPort = 2456, hostPort = 2456, protocol = "udp" },
        { containerPort = 2457, hostPort = 2457, protocol = "udp" },
        { containerPort = 2458, hostPort = 2458, protocol = "udp" }
      ]
    }
  ])
}

resource "aws_ecs_service" "valheim_service" {
  name            = "valheim-service"
  cluster         = aws_ecs_cluster.valheim_cluster.id
  task_definition = aws_ecs_task_definition.valheim_task.arn
  launch_type     = "FARGATE"
  desired_count   = 0

  network_configuration {
    subnets          = [aws_subnet.valheim_subnet.id]
    security_groups  = [aws_security_group.valheim_sg.id]
    assign_public_ip = true
  }
}

resource "aws_route53_zone" "valheim_ondemand_route53_zone" {
  name = "${var.project_name}.${var.domain_name}"
}
resource "aws_route53_record" "valheim_dns" {
  zone_id = aws_route53_zone.valheim_ondemand_route53_zone.id
  name    = "valheim.raeon.tech"
  type    = "A"
  ttl     = 30
  records = ["1.1.1.1"]
}

data "archive_file" "auto_start_lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/auto_start.py"
  output_path = "${path.module}/lambda/auto_start.zip"
}

data "archive_file" "backup_lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/backup.py"
  output_path = "${path.module}/lambda/backup.zip"
}

data "archive_file" "shutdown_lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/shutdown.py"
  output_path = "${path.module}/lambda/shutdown.zip"
}

resource "aws_lambda_function" "valheim_auto_start" {
  filename      = data.archive_file.auto_start_lambda.output_path
  function_name = "valheim_auto_start"
  role          = aws_iam_role.ondemand_valheim_task_starter_lambda_role.arn
  handler       = "auto_start.lambda_handler"
  runtime       = "python3.8"
  timeout       = 30
}

resource "aws_lambda_function" "valheim_backup" {
  filename      = data.archive_file.backup_lambda.output_path
  function_name = "valheim_backup"
  role          = aws_iam_role.ondemand_valheim_task_starter_lambda_role.arn
  handler       = "backup.lambda_handler"
  runtime       = "python3.8"
  timeout       = 60
  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.valheim_backup.id
    }
  }
}

resource "aws_lambda_function" "valheim_auto_shutdown" {
  filename      = data.archive_file.shutdown_lambda.output_path
  function_name = "valheim_auto_shutdown"
  role          = aws_iam_role.ondemand_valheim_task_starter_lambda_role.arn
  handler       = "shutdown.lambda_handler"
  runtime       = "python3.8"
  timeout       = 30
}

resource "aws_cloudwatch_event_rule" "valheim_backup_schedule" {
  name                = "valheim-backup-schedule"
  schedule_expression = "rate(1 hour)"
}

resource "aws_cloudwatch_event_rule" "valheim_shutdown_schedule" {
  name                = "valheim-shutdown-schedule"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "valheim_backup_target" {
  rule      = aws_cloudwatch_event_rule.valheim_backup_schedule.name
  target_id = "valheim-backup-lambda"
  arn       = aws_lambda_function.valheim_backup.arn
}

resource "aws_cloudwatch_event_target" "valheim_shutdown_target" {
  rule      = aws_cloudwatch_event_rule.valheim_shutdown_schedule.name
  target_id = "valheim-shutdown-lambda"
  arn       = aws_lambda_function.valheim_auto_shutdown.arn
}
