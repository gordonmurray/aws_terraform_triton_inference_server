resource "aws_key_pair" "triton" {
  key_name   = "triton"
  public_key = file("~/.ssh/id_rsa.pub")
}