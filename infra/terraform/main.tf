
resource "aws_vpc" "idp_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "idp-vpc"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.idp_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "idp-public-1"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.idp_vpc.id
  cidr_block        = "10.0.101.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "idp-private-1"
  }
}

resource "aws_internet_gateway" "idp_igw" {
  vpc_id = aws_vpc.idp_vpc.id

  tags = {
    Name = "idp-igw"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "idp_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = "idp-nat"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.idp_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.idp_igw.id
  }

  tags = {
    Name = "idp-public-rt"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.idp_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.idp_nat.id
  }

  tags = {
    Name = "idp-private-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}
