# Creates a ecr repository for lambda service
resource "aws_ecr_repository" "ecr-lambda" {
  name                 = var.ECR_LAMBDA_REPO_NAME
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
}
