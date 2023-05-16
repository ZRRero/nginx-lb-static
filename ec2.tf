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
  vpc_id = aws_vpc.main.id
  ingress {
    description      = "Public ingress on port 80"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
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
  vpc_id = aws_vpc.main.id
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
  iam_instance_profile {
    arn = aws_iam_instance_profile.static_instance_profile.arn
  }
  network_interfaces {
    security_groups = [aws_security_group.static_security_group.id]
    associate_public_ip_address = true
    delete_on_termination =true
  }
  user_data = filebase64("webconfig/user-data-static.sh")
  metadata_options {
    http_endpoint = "enabled"
    http_tokens = "required"
    instance_metadata_tags = "enabled"
  }
}

resource "aws_launch_template" "load_balancer_launch_template" {
  provider = aws.master_region
  name = "load_balancer_launch_template"
  image_id = data.aws_ami.base_ami.image_id
  instance_type = var.load_balancer_instance_type
  iam_instance_profile {
    arn = aws_iam_instance_profile.load_balancer_instance_profile.arn
  }
  network_interfaces {
    security_groups = [aws_security_group.load_balancer_security_group.id]
    associate_public_ip_address = true
    delete_on_termination =true
  }
  user_data = filebase64("webconfig/user-data-lb.sh")
  metadata_options {
    http_endpoint = "enabled"
    http_tokens = "required"
    instance_metadata_tags = "enabled"
  }
}

resource "aws_instance" "static_instance" {
  provider = aws.master_region
  count = var.static_instance_count
  launch_template {
    id = aws_launch_template.static_launch_template.id
    version = "$Latest"
  }
  tags = {
    "Number": count.index
    "Owner": "load_balancer"
    "Bucket": aws_s3_bucket.configuration_bucket.bucket
  }
  subnet_id = aws_subnet.public_subnets[count.index % length(aws_subnet.public_subnets)].id
}