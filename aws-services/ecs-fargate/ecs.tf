provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAZZ5YCGFPWULUHPM3"
  secret_key = "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"
}

resource "aws_security_group" "ecs-sg" {
  name   = "ecs-sg"
  vpc_id = "vpc-0540619b3a2942b44"

  ingress {
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_ecs_cluster" "ecs-cluster" {
  name = "ecs-cluster"
}


resource "aws_iam_role" "ecs_task_role" {
  name = "ecs_task_role"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}
 
resource "aws_iam_policy" "test" {
  name        = "task-policytest"
  description = "Policy that allows access to test"
 
 policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Effect": "Allow",
           "Action": [
               "*"
           ],
           "Resource": "*"
       }
   ]
}
EOF
}
 
resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.test.arn
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}
 
resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "ecs-td" {
  family                   = "ecs-td"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  runtime_platform {
    operating_system_family = "LINUX"
    #cpu_architecture        = "X86_64"
  }
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([
    {
      name      = "httpd-container"
      image     = "httpd"
      essential = true
      # environment = var.container_environment
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = 80
          hostPort      = 80
        }
      ]

    }
  ])
}

resource "aws_ecs_service" "ecs-svc" {
  name                               = "ecs-svc"
  cluster                            = aws_ecs_cluster.ecs-cluster.id
  task_definition                    = aws_ecs_task_definition.ecs-td.arn
  desired_count                      = 2
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups  = [aws_security_group.ecs-sg.id]
    subnets          = ["subnet-00dc489d00165ff8e", "subnet-0b052c78dad60b0bd", "subnet-08c282f729e06ddcf"]
    assign_public_ip = true
  }

   load_balancer {
     target_group_arn = aws_alb_target_group.ecs-alb-tg.arn
     container_name   = "httpd-container"
     container_port   = 80
   }
depends_on = [
  aws_alb_target_group.ecs-alb-tg
]
  #  lifecycle {
  #    ignore_changes = [task_definition, desired_count]
  #  }
}


resource "aws_lb" "ecs-alb" {
  name               = "ecs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs-sg.id]
  subnets            = ["subnet-00dc489d00165ff8e", "subnet-0b052c78dad60b0bd", "subnet-08c282f729e06ddcf"]
 
  enable_deletion_protection = false
}
 
resource "aws_alb_target_group" "ecs-alb-tg" {
  name        = "ecs-alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "vpc-0540619b3a2942b44"
  target_type = "ip"
 
  health_check {
   healthy_threshold   = "3"
   interval            = "30"
   protocol            = "HTTP"
   matcher             = "200"
   timeout             = "3"
   path                = "/"
   unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.ecs-alb.id
  port              = 80
  protocol          = "HTTP"
 
  default_action{
    type             = "forward"
    target_group_arn = aws_alb_target_group.ecs-alb-tg.arn
  }
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.ecs-cluster.name}/${aws_ecs_service.ecs-svc.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = "memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
 
  target_tracking_scaling_policy_configuration {
   predefined_metric_specification {
     predefined_metric_type = "ECSServiceAverageMemoryUtilization"
   }
 
   target_value       = 5
  }
}
 
resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
 
  target_tracking_scaling_policy_configuration {
   predefined_metric_specification {
     predefined_metric_type = "ECSServiceAverageCPUUtilization"
   }
 
   target_value       = 5
  }
}

