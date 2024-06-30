resource "aws_autoscaling_group" "triton_servers" {
  name                      = "nvidia-triton-inference-servers"
  desired_capacity          = 1
  max_size                  = 3
  min_size                  = 1
  vpc_zone_identifier       = var.subnets
  health_check_type         = "EC2"
  health_check_grace_period = 300
  force_delete              = true
  wait_for_capacity_timeout = "0"

  launch_template {
    id      = aws_launch_template.triton_servers.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "Nvidia Triton Inference server"
    propagate_at_launch = true
  }

}
