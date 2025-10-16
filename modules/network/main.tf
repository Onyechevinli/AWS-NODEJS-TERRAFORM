# VPC
resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = {
        Name = "${var.name}-vpc"
    }
}

# Internet Gateway for public access
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "${var.name}-igw"
    }   
}

# Public subnets
resource "aws_subnet" "public" {
    count = length(var.azs)
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnets[count.index]
    map_public_ip_on_launch = true
    availability_zone = var.azs[count.index]
    tags = {
        Name = format("%s-public-%d", var.name, count.index)
    }
}

# Private subnets
resource "aws_subnet" "private" {
    count = length(var.azs)
    vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]
    tags = {
        Name = format("%s-private-%d", var.name, count.index)
    }
}

# NAT Gateway per public subnet (high availability)
resource "aws_eip" "nat" {
    count = length(var.azs)
    domain = "vpc" # Required for VPC
    tags = {
        Name = format("%s-nat-eip-%d", var.name, count.index)
    }
}

resource "aws_nat_gateway" "nat" {
    count = length(var.azs)
    allocation_id = aws_eip.nat[count.index].id
    subnet_id = aws_subnet.public[count.index].id
}

# Route table for public subnets
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "${var.name}-public-rt"
    }
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}
resource "aws_route_table_association" "public" {
    count = length(var.azs)
    subnet_id = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public.id
}

# Route table for private subnets
resource "aws_route_table" "private" {
    count = length(var.azs)
    vpc_id = aws_vpc.main.id
    tags = {
        Name = format("%s-private-rt-%d", var.name, count.index)
    }
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat[count.index].id
    }
}

resource "aws_route_table_association" "private" {
    count = length(var.azs)
    subnet_id = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.private[count.index].id
}