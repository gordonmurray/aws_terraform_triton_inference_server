resource "aws_iam_instance_profile" "ec2_s3_write_profile" {
  name = "ec2_s3_write_profile"
  role = aws_iam_role.ec2_s3_write_role.name
  tags = var.tags
}