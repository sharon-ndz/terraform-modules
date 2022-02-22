resource "aws_ecr_repository" "aws-ecr" {
  name = "${var.app_name}-${var.env}-ecr"
  tags = {
    Name        = "${var.app_name}-ecr"
    Environment = var.env
  }
}