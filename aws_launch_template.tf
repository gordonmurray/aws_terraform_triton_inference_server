data "template_file" "init_script" {
  template = <<-EOF
      #!/bin/bash

      # Wait for the system to start up fully
      sleep 30

    # start docker containers

    EOF
}

resource "aws_launch_template" "triton_servers" {
  name                                 = "triton_servers"
  disable_api_stop                     = false
  disable_api_termination              = false
  ebs_optimized                        = true
  image_id                             = data.aws_ami.triton_ami.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = var.instance_type
  key_name                             = aws_key_pair.triton.key_name
  vpc_security_group_ids               = [aws_security_group.triton.id]
  user_data                            = base64encode(data.template_file.init_script.rendered)

  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2_s3_write_profile.arn
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = 500
      volume_type           = "gp3"
      throughput            = 125
      iops                  = 3000
      delete_on_termination = true
    }
  }

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  monitoring {
    enabled = true
  }

  placement {
    availability_zone = "${var.aws_region}a"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Nvidida Triton Inference Server"
    }
  }
}
