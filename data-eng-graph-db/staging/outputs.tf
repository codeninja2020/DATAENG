output "ecr_repository_url" {
  description = "Base ECR repository URL for the graph-db image (append :<git-sha> to form a full image URI for var.image)"
  value       = aws_ecr_repository.graph_db.repository_url
}
