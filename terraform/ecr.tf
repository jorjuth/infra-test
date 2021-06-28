
module "member_api_ecr" {
  source = "./modules/aws-ecr/"

  repository = var.project_prefix
  #kms_key    = aws_kms_key.this.arn
  kms_key = ""

  tags = merge(
    var.common_tags,
    {
      Environment = terraform.workspace
    }
  )
}
