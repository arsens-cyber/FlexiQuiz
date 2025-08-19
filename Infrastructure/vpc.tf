# Creates a dedicated VPC for the application
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

# Creates public subnets for the ALB and Fargate tasks
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true # Required for Fargate tasks in public subnets to pull images
  tags = {
    Name = "${local.name_prefix}-public-subnet-${count.index + 1}"
  }
}

# Retrieves available AZs in the region
data "aws_availability_zones" "available" {}

# Creates an Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${local.name_prefix}-igw"
  }
}

# Creates a route table to route traffic to the IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${local.name_prefix}-public-rt"
  }
}

# Associates the route table with the public subnets
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}