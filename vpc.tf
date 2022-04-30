# VPC
resource "aws_vpc" "aws-vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = {
    Name = "${var.application_name}-vpc"
    Env  = var.application_env
  }
}

# Internet Gateway For Public Setup
resource "aws_internet_gateway" "aws-igw" {
  vpc_id = aws_vpc.aws-vpc.id
  tags = {
    Name = "${var.application_name}-igw"
  }
}

# EIP for Public Nat Gateway
resource "aws_eip" "aws-web-eip" {
  vpc   = true
  count = length(var.pub_web_subnets_cidr)
  tags = {
    Name = "${var.application_name}-web-eip-${count.index + 1}"
  }
}

# Nat Gateway for Public AZ1 & AZ2
resource "aws_nat_gateway" "aws-web-nat-gateway" {
  count         = length(var.pub_web_subnets_cidr)
  subnet_id     = aws_subnet.aws-public-subnet[count.index].id
  allocation_id = aws_eip.aws-web-eip[count.index].id
  tags = {
    Name = "${var.application_name}-web-nat-gateway-${count.index + 1}"
  }
}

# Public Route Table
resource "aws_route_table" "aws-public-route-table" {
  count  = length(var.pub_web_subnets_cidr)
  vpc_id = aws_vpc.aws-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws-igw.id
  }

  tags = {
    Name = "${var.application_name}-public-route-table-${count.index + 1}"
  }
}

# Public Route table with associated public subnets
resource "aws_route_table_association" "aws-web-route-table-association" {
  count          = length(var.pub_web_subnets_cidr)
  subnet_id      = aws_subnet.aws-public-subnet[count.index].id
  route_table_id = aws_route_table.aws-public-route-table[count.index].id

}

# PRIVATE Route table with associated PRIVATE subnets
resource "aws_route_table" "aws-private-route-table" {
  count  = length(var.priv_app_subnets_cidr)
  vpc_id = aws_vpc.aws-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.aws-web-nat-gateway[count.index].id
  }

  tags = {
    Name = "${var.application_name}-private-route-table-${count.index + 1}"
  }
}

# PRIVATE Route table with associated PRIVATE subnets
resource "aws_route_table_association" "aws-private-route-table-association" {
  count          = length(var.priv_app_subnets_cidr)
  subnet_id      = aws_subnet.aws-private-subnet[count.index].id
  route_table_id = aws_route_table.aws-private-route-table[count.index].id
}


# Subnets : public-web
resource "aws_subnet" "aws-public-subnet" {
  count                   = length(var.pub_web_subnets_cidr)
  vpc_id                  = aws_vpc.aws-vpc.id
  cidr_block              = element(var.pub_web_subnets_cidr, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.application_name}-public-subnet-${count.index + 1}"
  }
}

# Subnets : private-subnet
resource "aws_subnet" "aws-private-subnet" {
  count                   = length(var.priv_app_subnets_cidr)
  vpc_id                  = aws_vpc.aws-vpc.id
  cidr_block              = element(var.priv_app_subnets_cidr, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.application_name}-private-subnet-${count.index + 1}"
  }
}
