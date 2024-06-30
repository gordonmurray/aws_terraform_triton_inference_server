resource "aws_security_group" "triton" {
  name        = "triton"
  description = "triton security group"
  vpc_id      = var.vpc_id
  tags        = var.tags
}