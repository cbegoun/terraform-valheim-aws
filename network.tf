resource "aws_vpc" "valheim" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "valheim" {
  vpc_id = aws_vpc.valheim.id
}

resource "aws_subnet" "valheim" {
  vpc_id            = aws_vpc.valheim.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"
}

resource "aws_route_table" "valheim" {
  vpc_id = aws_vpc.valheim.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.valheim.id
  }
}

resource "aws_route_table_association" "valheim" {
  subnet_id      = aws_subnet.valheim.id
  route_table_id = aws_route_table.valheim.id
}

resource "aws_security_group" "valheim_sg" {
  vpc_id = aws_vpc.valheim.id

  ingress {
    from_port   = 2456
    to_port     = 2458
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rdp" {
  vpc_id      = aws_vpc.valheim.id
  description = "Allow RDP inbound traffic"

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

resource "tls_private_key" "valheim" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "valheim_key" {
  key_name   = "valheim-key"
  public_key = tls_private_key.valheim.public_key_openssh
}
