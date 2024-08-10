# Create VPC
resource "aws_vpc" "k8s_vpc" {
  cidr_block = var.aws_vpc
  tags = {
    Name = "k8s_vpc"
  }
}

# Create privates subnets
resource "aws_subnet" "k8s_private_subnet" {
  count             = length(var.aws_subnet_private)
  vpc_id            = aws_vpc.k8s_vpc.id
  cidr_block        = var.aws_subnet_private[count.index]
  availability_zone = element(split(",", var.aws_availability_zone), count.index)
  tags = {
    Name = "k8s_private_subnet_${count.index}"
  }
}

# Create public subnets
resource "aws_subnet" "k8s_public_subnet" {
  count             = length(var.aws_subnet_public)
  vpc_id            = aws_vpc.k8s_vpc.id
  cidr_block        = var.aws_subnet_public[count.index]
  availability_zone = element(split(",", var.aws_availability_zone), count.index)
  tags = {
    Name = "k8s_public_subnet_${count.index}"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "k8s_igw" {
  vpc_id = aws_vpc.k8s_vpc.id
  tags = {
    Name = "k8s_igw"
  }
}

# Create public route table
resource "aws_route_table" "k8s_public_route_table" {
  vpc_id = aws_vpc.k8s_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s_igw.id
  }
  tags = {
    Name = "k8s_public_route_table"
  }
}

# Associate public route table with public subnets
resource "aws_route_table_association" "k8s_public_route_table_association" {
  depends_on     = [aws_subnet.k8s_public_subnet]
  count          = length(aws_subnet.k8s_public_subnet)
  subnet_id      = aws_subnet.k8s_public_subnet[count.index].id
  route_table_id = aws_route_table.k8s_public_route_table.id
}

# Create Elastic IP
resource "aws_eip" "k8s_eip" {
  vpc = true
}

# Create NAT gateway
resource "aws_nat_gateway" "k8s_nat_gateway" {
  allocation_id = aws_eip.k8s_eip.id
  subnet_id     = aws_subnet.k8s_public_subnet[0].id
  tags = {
    Name = "k8s_nat_gateway"
  }
}

# Create private route table
resource "aws_route_table" "k8s_private_route_table" {
  vpc_id = aws_vpc.k8s_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.k8s_nat_gateway.id
  }
  tags = {
    Name = "k8s_private_route_table"
  }
}

# Associate private route table with private subnets

resource "aws_route_table_association" "k8s_private_route_table_association" {
  depends_on     = [aws_subnet.k8s_private_subnet]
  count          = length(aws_subnet.k8s_private_subnet)
  subnet_id      = aws_subnet.k8s_private_subnet[count.index].id
  route_table_id = aws_route_table.k8s_private_route_table.id
}
