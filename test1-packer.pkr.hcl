packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "use_ubuntu" {
  type    = bool
  default = false
}

variable "use_redhat" {
  type    = bool
  default = true
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "packer-example-ubuntu-{{timestamp}}"
  instance_type = "t2.micro"
  region        = var.aws_region
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"] # Canonical
  }
  ssh_username = "ubuntu"
  tags = {
    "Name"        = "Af-xtern-A"
    "Environment" = "development"
    "OS_Version"  = "Ubuntu 20.04"
    "Release"     = "Latest"
    "Created-by"  = "Packer"
  }
}

source "amazon-ebs" "redhat" {
  ami_name      = "packer-example-redhat-{{timestamp}}"
  instance_type = "t3.micro"
  region        = var.aws_region
  source_ami_filter {
    filters = {
      name                = "RHEL-8.4.0_HVM-*-x86_64-*-Hourly2-GP2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["309956199498"] # Red Hat
  }
  ssh_username = "ec2-user"
  tags = {
    "Name"        = "Af-xtern-A"
    "Environment" = "development"
    "OS_Version"  = "RHEL 8.4"
    "Release"     = "Latest"
    "Created-by"  = "Packer"
  }
}

build {
  sources = var.use_ubuntu ? ["source.amazon-ebs.ubuntu"] : var.use_redhat ? ["source.amazon-ebs.redhat"] : []

  # Uncomment this if you are testing/running from your local system.
  provisioner "file" {
    source      = "packer-scripts"
    destination = "/tmp"
  }


  provisioner "shell" {
    inline = concat(
      var.use_ubuntu ? ["sudo apt update -y"] : [],
      var.use_redhat ? ["sudo yum update -y"] : [],
      [
        "sudo bash /tmp/packer-scripts/001-critical-standards.sh",
        "sudo bash /tmp/packer-scripts/002-critical-standards.sh"
      ]
    )
  }

  # Uncomment this if you are testing/running from your local system.
  # provisioner "file" {
  #   source      = "packer-scripts"
  #   destination = "/tmp"
  # }

  
}

