# Creates an ecr repository for factorial calculator
resource "aws_ecr_repository" "ecr-factorial" {
  name                 = var.ECR_FACTORIAL_REPO_NAME
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
}
