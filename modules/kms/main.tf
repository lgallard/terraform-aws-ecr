# ----------------------------------------------------------
# KMS Key Resource
# ----------------------------------------------------------

resource "aws_kms_key" "this" {
  description             = local.key_description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
  rotation_period_in_days = var.key_rotation_period
  multi_region            = var.multi_region
  key_usage               = var.key_usage

  policy = local.final_policy

  tags = local.final_tags
}

# ----------------------------------------------------------
# KMS Alias Resource
# ----------------------------------------------------------

resource "aws_kms_alias" "this" {
  count         = var.create_alias ? 1 : 0
  name          = "alias/${local.alias_name}"
  target_key_id = aws_kms_key.this.key_id

  lifecycle {
    create_before_destroy = true
  }
}
