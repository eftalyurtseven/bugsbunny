output "factorial_repository_url" {
  description = "The URL of the repository."
  value       = aws_ecr_repository.ecr-factorial.repository_url
}
output "lambda_repository_url" {
  description = "The URL of the repository."
  value       = aws_ecr_repository.ecr-lambda.repository_url
}
