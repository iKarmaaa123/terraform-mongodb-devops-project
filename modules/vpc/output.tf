output "vpc_id" {
    value = aws_vpc.my_vpc.id
}

output "route_table_cidr_block" {
    value = aws_vpc.my_vpc.cidr_block
}

output "route_table_id" {
    value = aws_route_table.my_route_table.id
}

output "aws_account_id" {
    value = "648767092427"
}




