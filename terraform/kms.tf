
resource "aws_kms_key" "this" {
  description              = "${var.project_name} API ${upper(terraform.workspace)} admin key"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 10
  enable_key_rotation      = true
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.project_prefix}-key"
  target_key_id = aws_kms_key.this.key_id
}
