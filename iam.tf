data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_role_policy_attachment" {
  role       = data.aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "valheim_ondemand_fargate_task_role" {
  name = "ecs.task.valheim-server"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

}

resource "aws_iam_policy" "valheim_ondemand_efs_access_policy" {
  name        = "valheim_ondemand_efs_access_policy"
  path        = "/"
  description = "Allows Read Write access to the valheim server EFS"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:DescribeFileSystems"
        ],
        "Resource" : aws_efs_file_system.valheim_ondemand_efs.arn,
        "Condition" : {
          "StringEquals" : {
            "elasticfilesystem:AccessPointArn" : aws_efs_access_point.valheim_ondemand_efs_access_point.arn
          }
        }
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "valheim_ondemand_efs_access_policy_attachment" {
  role       = aws_iam_role.valheim_ondemand_fargate_task_role.name
  policy_arn = aws_iam_policy.valheim_ondemand_efs_access_policy.arn
}

data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "valheim_ondemand_ecs_control_policy" {
  name        = "valheim_ondemand_ecs_control_policy"
  path        = "/"
  description = "Allows the valheim server ECS task to understand which network interface is attached to it in order to properly update the DNS records"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ecs:*"
        ],
        "Resource" : [
          aws_ecs_service.valheim_service.id,
          format("arn:aws:ecs:%s:%s:task/valheim/*", var.aws_region, data.aws_caller_identity.current.account_id)
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeNetworkInterfaces"
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "valheim_ondemand_ecs_control_policy_attachment" {
  role       = aws_iam_role.valheim_ondemand_fargate_task_role.name
  policy_arn = aws_iam_policy.valheim_ondemand_ecs_control_policy.arn
}

resource "aws_iam_policy" "valheim_ondemand_ecs_exec_policy" {
  name        = "valheim_ondemand_ecs_task_exec_policy"
  path        = "/"
  description = "Allows the valheim server ECS task to communicate with the SSM agent for ECS Exec"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        "Resource" : "*"
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "valheim_ondemand_ecs_exec_policy_attachment" {
  role       = aws_iam_role.valheim_ondemand_fargate_task_role.name
  policy_arn = aws_iam_policy.valheim_ondemand_ecs_exec_policy.arn
}

resource "aws_iam_policy" "valheim_ondemand_route53_update_policy" {
  name        = "valheim_ondemand_route53_update_policy"
  path        = "/"
  description = "Allows the valheim server ECS task to update DNS records on a hosted zone"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:GetHostedZone",
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets"
        ],
        "Resource" : aws_route53_zone.valheim_ondemand_route53_zone.arn
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ListHostedZones"
        ],
        "Resource" : "*"
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "valheim_ondemand_route53_update_policy_attachment" {
  role       = aws_iam_role.valheim_ondemand_fargate_task_role.name
  policy_arn = aws_iam_policy.valheim_ondemand_route53_update_policy.arn
}

# Lambda Role

resource "aws_iam_role" "ondemand_valheim_task_starter_lambda_role" {
  name = "ondemand_valheim_task_starter_lambda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "valheim_ondemand_ecs_control_policy_attachment_lambda" {
  role       = aws_iam_role.ondemand_valheim_task_starter_lambda_role.name
  policy_arn = aws_iam_policy.valheim_ondemand_ecs_control_policy.arn
}

resource "aws_iam_role_policy_attachment" "valheim_ondemand_lambda_cloudwatch_logging_policy_attachment" {
  role       = aws_iam_role.ondemand_valheim_task_starter_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


# Cloudwatch Route53 logging policy document

data "aws_iam_policy_document" "route53-query-logging-policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:log-group:/aws/route53/*"]

    principals {
      identifiers = ["route53.amazonaws.com"]
      type        = "Service"
    }
  }
}