output "aws_vpc_id" {
   value = aws_vpc.this.id
}

output "vpc_public_subnet_azs" {
   value = aws_subnet.vpc_public_subnet[*].id
}

output "vpc_app_subnet_azs" {
   value = aws_subnet.vpc_app_subnet[*].id
}


output "vpc_public_subnet_az1" {
   value = aws_subnet.vpc_public_subnet[0].id
}

output "vpc_app_subnet_az1" {
   value = aws_subnet.vpc_app_subnet[0].id
}

output "vpc_db_subnet_ids" {
   value = aws_subnet.vpc_db_subnet[*].id
}

output "vpc_db_subnet_name" {
   value = aws_subnet.vpc_db_subnet[0].id
}

output "vpc_db_subnet_az1" {
   value = aws_subnet.vpc_db_subnet[0].id
}

output "vpc_public_subnet_az2" {
   value = aws_subnet.vpc_public_subnet[1].id
}

output "vpc_app_subnet_az2" {
   value = aws_subnet.vpc_app_subnet[1].id
}

output "vpc_db_subnet_az2" {
   value = aws_subnet.vpc_db_subnet[1].id
}

output "vpc_public_subnet_az3" {
   value = aws_subnet.vpc_public_subnet[2].id
}

output "vpc_app_subnet_az3" {
   value = aws_subnet.vpc_app_subnet[2].id
}

output "vpc_db_subnet_az3" {
   value = aws_subnet.vpc_db_subnet[2].id
}

output "vpc_default_gateway_id" {
    value = aws_internet_gateway.igw.id
}

output "vpc_aws_route_table_public_subnet_ids" {
  value = aws_route_table.public_subnet.*.id
}

output "vpc_aws_route_table_app_subnet_ids" {
  value = aws_route_table.app_subnet.*.id
}


output "vpc_nat_gateways" {
  value = aws_nat_gateway.NGW.*.id
}



