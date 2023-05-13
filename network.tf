resource "aws_vpc" "main" {
  provider = aws.master_region
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "Main VPC"
  }
}

resource "aws_subnet" "public_subnets" {
  provider = aws.master_region
  count = length(var.availability_zones)
  cidr_block = var.public_cidr_blocks[count.index]
  vpc_id     = aws_vpc.main.id
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_${var.availability_zones[count.index]}"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  provider = aws.master_region
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public_route_table" {
  provider = aws.master_region
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name = "subnet_public_route_table"
  }
}

resource "aws_route_table_association" "public_route_table_associations" {
  provider = aws.master_region
  count = length(aws_subnet.public_subnets)
  route_table_id = aws_route_table.public_route_table.id
  subnet_id = aws_subnet.public_subnets[count.index].id
}