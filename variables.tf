variable "aws_account_id" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "tags" {
  type = map(string)
  default = {
    "Name" = "Nvidia Triton Inference Server"
  }
}

variable "instance_type" {
  type    = string
  default = "g5.xlarge"
}
