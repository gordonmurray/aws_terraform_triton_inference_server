resource "aws_security_group_rule" "triton_http" {
  type              = "ingress"
  from_port         = 8000
  to_port           = 8000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.triton.id
  description       = "Allow HTTP traffic to Triton Inference Server"
}

resource "aws_security_group_rule" "triton_grpc" {
  type              = "ingress"
  from_port         = 8001
  to_port           = 8001
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.triton.id
  description       = "Allow gRPC traffic to Triton Inference Server"
}

resource "aws_security_group_rule" "triton_metrics" {
  type              = "ingress"
  from_port         = 8002
  to_port           = 8002
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.triton.id
  description       = "Allow metrics traffic to Triton Inference Server"
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.triton.id
  description       = "Allow all outbound traffic"
}