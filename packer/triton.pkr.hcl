packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "base_ami_id" {
  type    = string
  default = "ami-0607a9783dd204cae"
}

variable "profile" {
  type    = string
  default = "gordonmurray"
}

variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "instance_type" {
  type    = string
  default = "g5.xlarge"
}

source "amazon-ebs" "ubuntu" {
  ami_name         = "triton_g5_xlarge_ubuntu"
  instance_type    = var.instance_type
  force_deregister = true
  region           = var.region
  source_ami       = var.base_ami_id
  ssh_username     = "ubuntu"
  profile          = var.profile
  tags = {
    Name = "triton_g5_xlarge_ubuntu_22_04"
  }

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 200
    volume_type           = "gp3"
    delete_on_termination = true
  }

}

build {
  name = "triton-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "sudo apt-add-repository ppa:ansible/ansible",
      "sudo apt-get update",
      "sudo apt-get install -y ansible"
    ]
  }

  provisioner "ansible-local" {
    playbook_file = "../ansible/playbook.yml"
    role_paths    = [
      "../ansible/roles/docker_ce",
      "../ansible/roles/nvidia_triton"
      ]
  }

}
