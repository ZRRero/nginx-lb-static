data "aws_ami" "base_ami" {
  owners = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "load_balancer_security_group" {
  provider = aws.master_region
  name = "load_balancer_security_group"
  vpc_id = var.vpc_id
  ingress {
    description      = "Public ingress on port 80"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0"]
  }
  egress {
    description = "Public egress"
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "static_security_group" {
  provider = aws.master_region
  name = "static_security_group"
  vpc_id = var.vpc_id
  ingress {
    description = "Access from load_balancer_security_group on port 80"
    from_port = 80
    protocol  = "tcp"
    to_port   = 80
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }
  egress {
    description = "Public egress"
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "static_launch_template" {
  provider = aws.master_region
  name = "static_launch_template"
  image_id = data.aws_ami.base_ami.image_id
  instance_type = var.static_instance_type

}