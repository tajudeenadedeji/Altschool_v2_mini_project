# create a vpc
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "${var.project_name}-VPC"
  }
}

# data to retreive availability zone in each region
data "aws_availability_zones" "availability_zones" {}

#create a subnet
resource "aws_subnet" "my_subnet" {
  count = length(var.public_subnets_cidr)
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = var.public_subnets_cidr[count.index]
  availability_zone = data.aws_availability_zones.availability_zones.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}_subnet${count.index+1}"
  }
}

# create internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  
  tags = {
    Name = "${var.project_name}_igw"
  }
}

# create route table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  
  tags = {
    Name = "${var.project_name}_route_table"
  }
}

# create route table association
resource "aws_route_table_association" "my_route_table_association" {
  count = length(var.public_subnets_cidr)
  subnet_id = aws_subnet.my_subnet[count.index].id
  route_table_id = aws_route_table.my_route_table.id
}
