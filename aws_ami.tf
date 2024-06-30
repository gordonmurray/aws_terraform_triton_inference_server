data "aws_ami" "triton_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["triton_g5_xlarge_ubuntu"]
  }
  owners = [var.aws_account_id]
}