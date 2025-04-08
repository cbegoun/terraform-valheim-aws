data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "valheim_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "valheim-vpc"
  }
}

resource "aws_internet_gateway" "valheim_igw" {
  vpc_id = aws_vpc.valheim_vpc.id
  tags = {
    Name = "valheim-igw"
  }
}

resource "aws_subnet" "valheim_subnet" {
  vpc_id            = aws_vpc.valheim_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "valheim-subnet"
  }
}

resource "aws_route_table" "valheim_rt" {
  vpc_id = aws_vpc.valheim_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.valheim_igw.id
  }

  tags = {
    Name = "valheim-rt"
  }
}

resource "aws_route_table_association" "valheim_rta" {
  subnet_id      = aws_subnet.valheim_subnet.id
  route_table_id = aws_route_table.valheim_rt.id
}

resource "aws_security_group" "valheim_sg" {
  name   = "valheim-sg"
  vpc_id = aws_vpc.valheim_vpc.id

  # Valheim UDP ports
  ingress {
    from_port   = 2456
    to_port     = 2458
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # RDP for you
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [var.your_ip_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "valheim-sg"
  }
}

resource "aws_network_interface" "valheim_eni" {
  subnet_id       = aws_subnet.valheim_subnet.id
  security_groups = [aws_security_group.valheim_sg.id]
}