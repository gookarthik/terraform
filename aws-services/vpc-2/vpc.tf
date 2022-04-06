provider "aws" {
  region     = "us-west-1"
  access_key = "AKIA44DFE7A4UTJQJDMS"
  secret_key = "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"
}

resource "aws_vpc" "vpc1" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "vpc1"
  }
}
resource "aws_vpc" "vpc2" {
  cidr_block       = "11.0.0.0/16"

  tags = {
    Name = "vpc2"
  }
}
resource "aws_vpc" "vpc3" {
  cidr_block       = "12.0.0.0/16"

  tags = {
    Name = "vpc3"
  }
}
resource "aws_internet_gateway" "gw-1" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "gw-1"
  }
}
resource "aws_internet_gateway" "gw-2" {
  vpc_id = aws_vpc.vpc2.id

  tags = {
    Name = "gw-2"
  }
}
resource "aws_internet_gateway" "gw-3" {
  vpc_id = aws_vpc.vpc3.id

  tags = {
    Name = "gw-3"
  }
}
resource "aws_subnet" "main-public-1" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "main-public-1"
  }
}
resource "aws_subnet" "main-public-2" {
  vpc_id     = aws_vpc.vpc2.id
  cidr_block = "11.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "main-public-2"
  }
}
resource "aws_subnet" "main-public-3" {
  vpc_id     = aws_vpc.vpc3.id
  cidr_block = "12.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "main-public-3"
  }
}

resource "aws_route_table" "public-route-table-1" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw-1.id
  }


  tags = {
    Name = "public-route-table-1"
  }
}
resource "aws_route_table" "public-route-table-2" {
  vpc_id = aws_vpc.vpc2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw-2.id
  }


  tags = {
    Name = "public-route-table-2"
  }
}
resource "aws_route_table" "public-route-table-3" {
  vpc_id = aws_vpc.vpc3.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw-3.id
  }


  tags = {
    Name = "public-route-table-3"
  }
}

resource "aws_route_table_association" "a-1" {
  subnet_id      = aws_subnet.main-public-1.id
  route_table_id = aws_route_table.public-route-table-1.id
}
resource "aws_route_table_association" "a-2" {
  subnet_id      = aws_subnet.main-public-2.id
  route_table_id = aws_route_table.public-route-table-2.id
}
resource "aws_route_table_association" "a-3" {
  subnet_id      = aws_subnet.main-public-3.id
  route_table_id = aws_route_table.public-route-table-3.id
}

resource "aws_subnet" "main-private-1" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name = "main-private-1"
  }
}

resource "aws_eip" "lb-1" {
  vpc      = true
}

resource "aws_subnet" "main-private-2" {
  vpc_id     = aws_vpc.vpc2.id
  cidr_block = "11.0.2.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name = "main-private-2"
  }
}

resource "aws_eip" "lb-2" {
  vpc      = true
}

resource "aws_subnet" "main-private-3" {
  vpc_id     = aws_vpc.vpc3.id
  cidr_block = "12.0.2.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name = "main-private-3"
  }
}

resource "aws_eip" "lb-3" {
  vpc      = true
}

resource "aws_nat_gateway" "main-nat-gw-1" {
  allocation_id = aws_eip.lb-1.id
  subnet_id     = aws_subnet.main-public-1.id

  tags = {
    Name = "main-nat-gw-1"
  }

  depends_on = [aws_internet_gateway.gw-1]
}

resource "aws_nat_gateway" "main-nat-gw-2" {
  allocation_id = aws_eip.lb-2.id
  subnet_id     = aws_subnet.main-public-2.id

  tags = {
    Name = "main-nat-gw-2"
  }

  depends_on = [aws_internet_gateway.gw-2]
}

resource "aws_nat_gateway" "main-nat-gw-3" {
  allocation_id = aws_eip.lb-3.id
  subnet_id     = aws_subnet.main-public-3.id

  tags = {
    Name = "main-nat-gw-3"
  }

  depends_on = [aws_internet_gateway.gw-3]
}

resource "aws_route_table" "private-route-table-1" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main-nat-gw-1.id
  }


  tags = {
    Name = "private-route-table-1"
  }
}

resource "aws_route_table" "private-route-table-2" {
  vpc_id = aws_vpc.vpc2.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main-nat-gw-2.id
  }


  tags = {
    Name = "private-route-table-2"
  }
}

resource "aws_route_table" "private-route-table-3" {
  vpc_id = aws_vpc.vpc3.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main-nat-gw-3.id
  }


  tags = {
    Name = "private-route-table-3"
  }
}

resource "aws_route_table_association" "b-1" {
  subnet_id      = aws_subnet.main-private-1.id
  route_table_id = aws_route_table.private-route-table-1.id
}

resource "aws_route_table_association" "b-2" {
  subnet_id      = aws_subnet.main-private-2.id
  route_table_id = aws_route_table.private-route-table-2.id
}

resource "aws_route_table_association" "b-3" {
  subnet_id      = aws_subnet.main-private-3.id
  route_table_id = aws_route_table.private-route-table-3.id
}

resource "aws_vpc_peering_connection" "peer-1" {
  peer_vpc_id   = aws_vpc.vpc2.id
  vpc_id        = aws_vpc.vpc1.id
  auto_accept   = true
}

resource "aws_vpc_peering_connection" "peer-2" {
  peer_vpc_id   = aws_vpc.vpc3.id
  vpc_id        = aws_vpc.vpc2.id
  auto_accept   = true
}