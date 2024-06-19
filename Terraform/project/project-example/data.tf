# Search AMI
data "aws_ami" "amz2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name = "name"
    values = [
      "al2023-ami-2023.4.20240611.0-kernel-6.1-x86_64"
    ]
  }

  filter {
    name = "architecture"
    values = [
      "x86_64"
    ]
  }
}

data "aws_ami" "ubuntu2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name = "name"
    values = [
      "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20240319"
    ]
  }

  filter {
    name = "architecture"
    values = [
      "x86_64"
    ]
  }
}
