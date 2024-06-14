output "ecr_repo_url" {
  # value = aws_ecr_repository.ecr_repo.repository_url
  value = "${var.ecr_uri}${aws_ecr_repository.ecr_repo.name}"

}
