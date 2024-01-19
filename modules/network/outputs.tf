# output value for vpc
output "project_vpc_id" {
  value = aws_vpc.my_vpc.id
}

# output value for 3 subnets count using asteric (*)
output "project_subnet_id" {
  value = aws_subnet.my_subnet[*].id
}

