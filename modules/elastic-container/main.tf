locals {
  base_name     = "${lower(var.project)}-${lower(var.environment)}-${lower(var.service_name)}"
  alb_sg_name   = "${local.base_name}-alb-sg"
  ecs_sg_name   = "${local.base_name}-ecs-sg"
  cluster_name  = "${local.base_name}-cluster"
  tg_name       = "${local.base_name}-tg"
  lb_name       = "${local.base_name}-alb"
  service_name  = "${local.base_name}-service"
  exec_role_name = "${local.base_name}-exec-role"
  task_role_name = "${local.base_name}-task-role"
  log_group_name = "/ecs/${local.base_name}"
}

# --- Security Groups ---
resource "aws_security_group" "alb_sg" {
  name        = local.alb_sg_name
  description = "ALB public ingress for ${local.base_name}"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = local.alb_sg_name
  }
}

resource "aws_security_group" "ecs_tasks_sg" {
  name        = local.ecs_sg_name
  description = "ECS tasks SG for ${local.base_name}"
  vpc_id      = var.vpc_id

  # Only allow traffic from ALB on container port
  ingress {
    description     = "From ALB"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = local.ecs_sg_name
  }
}

# --- Load Balancer ---
resource "aws_lb" "this" {
  name               = local.lb_name
  load_balancer_type = "application"
  internal           = false
  subnets            = var.public_subnet_ids
  security_groups    = [aws_security_group.alb_sg.id]

  tags = {
    Name = local.lb_name
  }
}

resource "aws_lb_target_group" "this" {
  name        = local.tg_name
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = var.health_check_path
    protocol            = "HTTP"
    matcher             = "200-399"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
  }

  tags = {
    Name = local.tg_name
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

# --- CloudWatch Logs for ECS ---
resource "aws_cloudwatch_log_group" "ecs" {
  name              = local.log_group_name
  retention_in_days = 14
}

# --- IAM for ECS Task Execution (pull from ECR, write logs) ---
resource "aws_iam_role" "task_execution_role" {
  name               = local.exec_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
}

data "aws_iam_policy_document" "ecs_tasks_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "task_exec_attach" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Optional: allow ECR GetAuth (covered by the managed policy) and CW logs.

# --- (Optional) Task Role (for app's AWS calls). Here it's empty, provided if you need future access. ---
resource "aws_iam_role" "task_role" {
  name               = local.task_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
}

# --- ECS Cluster ---
resource "aws_ecs_cluster" "this" {
  name = local.cluster_name
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = {
    Name = local.cluster_name
  }
}

# --- Task Definition ---
resource "aws_ecs_task_definition" "this" {
  family                   = local.base_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.task_cpu)
  memory                   = tostring(var.task_memory)
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = "${var.ecr_repo_url}:${var.image_tag}"
      essential = true
      portMappings = [{
        containerPort = var.container_port
        hostPort      = var.container_port
        protocol      = "tcp"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = local.log_group_name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = var.container_name
        }
      }
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:${var.container_port}${var.health_check_path} || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 10
      }
    }
  ])
}

data "aws_region" "current" {}

# --- ECS Service (Fargate) ---
resource "aws_ecs_service" "this" {
  name            = local.service_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.public_subnet_ids        # per your request: use public subnets
    security_groups = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.http]

  lifecycle {
    ignore_changes = [task_definition] # optional: if you update TD outside of TF
  }

  tags = {
    Name = local.service_name
  }
}
