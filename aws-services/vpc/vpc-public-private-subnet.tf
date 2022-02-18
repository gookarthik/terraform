provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAZZ5YCGFPWULUHPM3"
  secret_key = "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"
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}


resource "aws_subnet" "main-public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "main-public"
  }
}


resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }


  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main-public.id
  route_table_id = aws_route_table.public-route-table.id
}


resource "aws_security_group" "main-sg" {
  name        = "main-sg"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
 
  }

  tags = {
    Name = "main-sg"
  }
}


resource "aws_instance" "web" {
  ami           = "ami-033b95fb8079dc481"
  instance_type = "t2.micro"
  key_name = "main"
#   vpc_security_group_ids = ["${aws_security_group.main-sg.id}"]
security_groups = ["${aws_security_group.main-sg.id}"]
  subnet_id = aws_subnet.main-public.id

  tags = {
    Name = "public-server"
  }
}

resource "aws_subnet" "main-private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name = "main-private"
  }
}

resource "aws_eip" "lb" {
  vpc      = true
}

resource "aws_nat_gateway" "main-nat-gw" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.main-public.id

  tags = {
    Name = "main-nat-gw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main-nat-gw.id
  }


  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.main-private.id
  route_table_id = aws_route_table.private-route-table.id
}

resource "aws_instance" "private-instance" {
  ami           = "ami-033b95fb8079dc481"
  instance_type = "t2.micro"
  key_name = "main"
#   vpc_security_group_ids = ["${aws_security_group.main-sg.id}"]
security_groups = ["${aws_security_group.main-sg.id}"]
  subnet_id = aws_subnet.main-private.id

  tags = {
    Name = "private-server"
  }
}

