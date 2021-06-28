
resource "aws_ecr_repository" "this" {
  name                 = var.repository
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = var.kms_key != "" ? "KMS" : "AES256"
    kms_key         = var.kms_key
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    var.tags,
    {
      Name = var.repository
    }
  )
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.id

  policy = <<POLICY
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Expire images older than 1 days",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 1
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
POLICY
}
