resource "aws_security_group" "server_sg" {
  name        = "${var.project}-${var.environment}-server-sg"
  description = "Allow SSH and App Access"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP for App Server"
    from_port   = 80
    to_port     = 80
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

resource "aws_instance" "app" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.server_sg.id]

  root_block_device {
    volume_size = 80
  }

  tags = {
    Name = "${var.project}-${var.environment}-ec2-app"
  }
}

resource "aws_eip" "app_eip" {
  vpc = true
}

resource "aws_eip_association" "app_eip_assoc" {
  instance_id   = aws_instance.app.id
  allocation_id = aws_eip.app_eip.id
}

resource "aws_instance" "redis" {
  ami           = var.ami_id
  instance_type = "t3.medium"
  subnet_id     = var.subnet_id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.server_sg.id]

  root_block_device {
    volume_size = 8
  }

  tags = {
    Name = "${var.project}-${var.environment}-ec2-redis"
  }
}

resource "aws_eip" "redis_eip" {
  vpc = true
}

resource "aws_eip_association" "redis_eip_assoc" {
  instance_id   = aws_instance.redis.id
  allocation_id = aws_eip.redis_eip.id
}
