resource "aws_vpc" "dev_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "dev-vpc"
  }
}

resource "aws_subnet" "dev_public_subnet" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    "Name" = "dev-public-subnet"
  }
}

resource "aws_internet_gateway" "dev_internet_gateway" {
  vpc_id = aws_vpc.dev_vpc.id
  tags = {
    "Name" = "dev-internet-gateway"
  }
}

resource "aws_route_table" "dev_route_table" {
  vpc_id = aws_vpc.dev_vpc.id
  tags = {
    "Name" = "dev-route-table"
  }
}

resource "aws_route" "dev_default_route" {
  route_table_id         = aws_route_table.dev_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dev_internet_gateway.id
}

resource "aws_route_table_association" "dev_route_table_association" {
  subnet_id      = aws_subnet.dev_public_subnet.id
  route_table_id = aws_route_table.dev_route_table.id
}

resource "aws_security_group" "dev_security_group" {
  name        = "dev-security-group"
  description = "dev-security-group"
  vpc_id      = aws_vpc.dev_vpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["--> YOUR IP <--"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "dev_keypair" {
  key_name   = "dev-keypair"
  public_key = file("~/.ssh/key-pair.pub")
}

resource "aws_instance" "dev_instance" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.dev_ami.id
  key_name               = aws_key_pair.dev_keypair.id
  vpc_security_group_ids = [aws_security_group.dev_security_group.id]
  subnet_id              = aws_subnet.dev_public_subnet.id
  root_block_device {
    volume_size = 10
  }
  tags = {
    Name = "dev-instance"
  }
}