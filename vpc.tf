# VPC
resource "aws_vpc" "task1_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = {
    Name = "task1_vpc"
  }
}

# Internet Gateway For Public Setup
resource "aws_internet_gateway" "task1_igw" {
  vpc_id = aws_vpc.task1_vpc.id
  tags = {
    Name = "task1_igw"
  }
}

########

# EIP for Public Nat Gateway
resource "aws_eip" "task1_eip_public_nat_gateway" {
  vpc   = true
  count = length(var.pub_web_subnets_cidr)
  tags = {
    Name = "task1_eip_public_nat_gateway-${count.index + 1}"
  }
}
#######
# Nat Gateway for Public AZ1 & AZ2
resource "aws_nat_gateway" "task1_public_nat_gateway" {
  count         = length(var.pub_web_subnets_cidr)
  subnet_id     = aws_subnet.task1_public_web[count.index].id
  allocation_id = aws_eip.task1_eip_public_nat_gateway[count.index].id
  tags = {
    Name = "task1_public_nat_gateway-${count.index + 1}"
  }
}

# Public Route Table
resource "aws_route_table" "task1_public_route_table" {
  count  = length(var.pub_web_subnets_cidr)
  vpc_id = aws_vpc.task1_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.task1_igw.id
  }

  tags = {
    Name = "task1_public_route_table-${count.index + 1}"
  }
}

# Public Route table with associated public subnets
resource "aws_route_table_association" "task1_public_route_table_association" {
  count          = length(var.pub_web_subnets_cidr)
  subnet_id      = aws_subnet.task1_public_web[count.index].id
  route_table_id = aws_route_table.task1_public_route_table[count.index].id

}

# PRIVATE Route table with associated PRIVATE subnets
resource "aws_route_table" "task1_private_route_table" {
  count  = length(var.priv_app_subnets_cidr)
  vpc_id = aws_vpc.task1_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.task1_public_nat_gateway[count.index].id
  }

  tags = {
    Name = "task1_private_route_table-${count.index + 1}"
  }
}


# PRIVATE Route table with associated PRIVATE subnets
resource "aws_route_table_association" "task1_private_route_table_association" {
  count          = length(var.priv_app_subnets_cidr)
  subnet_id      = aws_subnet.task1_private_app[count.index].id
  route_table_id = aws_route_table.task1_private_route_table[count.index].id
}


# Subnets : public-web
resource "aws_subnet" "task1_public_web" {
  count                   = length(var.pub_web_subnets_cidr)
  vpc_id                  = aws_vpc.task1_vpc.id
  cidr_block              = element(var.pub_web_subnets_cidr, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "task1_public_web_subnet-${count.index + 1}"
  }
}

# Subnets : private-app
resource "aws_subnet" "task1_private_app" {
  count                   = length(var.priv_app_subnets_cidr)
  vpc_id                  = aws_vpc.task1_vpc.id
  cidr_block              = element(var.priv_app_subnets_cidr, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = "task1_private_app_subnet-${count.index + 1}"
  }
}

