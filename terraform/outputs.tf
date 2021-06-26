
output "docker_commands" {
  value = <<EOF
  docker pull ${var.docker_image.repo}/${var.docker_image.name}
  docker tag ${var.docker_image.repo}/${var.docker_image.name}:${var.docker_image.tag} ${module.member_api_ecr.repository["member-api"].repository_url}/${var.docker_image.name}:${var.docker_image.tag}

  aws ecr get-login-password --profile ${lookup(var.aws_account, terraform.workspace)} --region ${lookup(var.aws_region, terraform.workspace)} | docker login --username AWS --password-stdin ${module.member_api_ecr.repository["member-api"].repository_url}
docker push ${module.member_api_ecr.repository["member-api"].repository_url}/${var.docker_image.name}:${var.docker_image.tag}
EOF
}
