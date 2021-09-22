resource "aws_security_group" "ecs_security_group" {
  name        = "${var.add_ecs_name}-SG"
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
  tags = merge({ Name = "${var.add_ecs_name}-SG" }, tomap(var.additional_tags))
}

resource "aws_security_group" "ecs_alb_security_group" {
  name        = "${var.add_ecs_name}-ALB-SG"
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
  name = var.add_ecs_name
}


