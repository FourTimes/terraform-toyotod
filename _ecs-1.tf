resource "aws_security_group" "ecs_security_group" {
  name        = "${var.ecs_name}-SG"
  description = "Security group for ECS to communicate in and out"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 32768
    protocol    = "TCP"
    to_port     = 65535
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 22
    protocol    = "TCP"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge({ Name = "${var.ecs_name}-SG" }, tomap(var.additional_tags))
}

resource "aws_security_group" "ecs_alb_security_group" {
  name        = "${var.ecs_name}-ALB-SG"
  description = "Security group for ALB to traffic for ECS cluster"
  vpc_id      = var.vpc_id

  # ingress {
  #   from_port   = 443
  #   protocol    = "TCP"
  #   to_port     = 443
  #   cidr_blocks = [var.internet_cidr_block]
  # }

  ingress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "fargate-cluster" {
  name = var.ecs_name
}

resource "aws_alb" "ecs_cluster_alb" {
  name            = "${var.ecs_cluster_name}-ALB"
  internal        = false
  security_groups = [aws_security_group.ecs_alb_security_group.id]
  subnets         = [var.subnet_2_id, var.subnet_1_id]
  tags            = merge({ Name = "${var.ecs_name}-ALB" }, tomap(var.additional_tags))
}

# resource "aws_alb_listener" "ecs_alb_https_listener" {
#   load_balancer_arn = aws_alb.ecs_cluster_alb.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
#   certificate_arn   = aws_acm_certificate.ecs_domain_certificate.arn
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_alb_target_group.ecs_default_target_group.arn
#   }
#   depends_on = [aws_alb_target_group.ecs_default_target_group]
# }

resource "aws_alb_target_group" "ecs_default_target_group" {
  name     = "${var.ecs_cluster_name}-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  tags     = merge({ Name = "${var.ecs_name}-TG" }, tomap(var.additional_tags))
}

resource "aws_iam_role" "ecs_cluster_role" {
  name = "${var.ecs_name}-iam-role"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : ["ecs.amazonaws.com", "ec2.amazonaws.com", "application-autoscaling.amazonaws.com"]
          },
          "Action" : "sts:AssumeRole"
        }
      ]
  })
}

resource "aws_iam_role_policy" "ecs_cluster_policy" {
  name = "${var.ecs_cluster_name}-iam-role"
  role = aws_iam_role.ecs_cluster_role.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "ecs:*",
            "ec2:*",
            "elasticloadbalancing:*",
            "ecr:*",
            "dynamodb:*",
            "cloudwatch:*",
            "s3:*",
            "rds:*",
            "sqs:*",
            "sns:*",
            "logs:*",
            "ssm:*"
          ],
          "Resource" : "*"
        }
      ]
  })
}
