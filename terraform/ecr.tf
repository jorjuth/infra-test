
module "member_api_ecr" {
  source = "./modules/ecr/"

  repositories = var.project_prefix
  kms_key      = aws_kms_key.this.arn

  tags = merge(
    var.common_tags,
    {
      Environment = terraform.workspace
    }
  )
}
