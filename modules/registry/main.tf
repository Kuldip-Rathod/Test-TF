resource "aws_ecr_repository" "this" {
  name = "${lower(var.project)}-${lower(var.environment)}-ecr-${lower(var.ecr_repo_name)}"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project}-${var.environment}-ecr-${var.ecr_repo_name}"
  }
}
