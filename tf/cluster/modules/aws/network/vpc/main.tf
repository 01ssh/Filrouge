resource "aws_vpc" "this" {
 cidr_block             = var.vpc_cidr_block
 tags = {
   Name = "${var.vpc_name}"
   environment = var.environment
 }
}

resource "aws_subnet" "vpc_public_subnet" {
 count      = length(var.vpc_public_subnet)
 vpc_id     = aws_vpc.this.id
 cidr_block = element(var.vpc_public_subnet, count.index)
 availability_zone = element(var.vpc_azs, count.index)
 map_public_ip_on_launch = "true"

 tags = {
   Name = "az_${element(var.vpc_azs, count.index)}_public_subnet_${count.index + 1}"
   "kubernetes.io/role/elb" = 1
   "kubernetes.io/cluster/${var.cluster_name}" = "shared"
   environment = var.environment
 }
}

resource "aws_subnet" "vpc_app_subnet" {
 count      = length(var.vpc_app_subnet)
 vpc_id     = aws_vpc.this.id
 cidr_block = element(var.vpc_app_subnet, count.index)
 availability_zone = element(var.vpc_azs, count.index)
 map_public_ip_on_launch = "true"

 tags = {
   Name = "az_${element(var.vpc_azs, count.index)}_app_subnet_${count.index + 1}"
   "kubernetes.io/role/internal-elb" = 1
   "kubernetes.io/cluster/${var.cluster_name}" = "shared"
   environment = var.environment
 }
}

resource "aws_subnet" "vpc_db_subnet" {
 count      = length(var.vpc_db_subnet)
 vpc_id     = aws_vpc.this.id
 cidr_block = element(var.vpc_db_subnet, count.index)
 availability_zone = element(var.vpc_azs, count.index)
 map_public_ip_on_launch = "true"

 tags = {
   Name = "az_${element(var.vpc_azs, count.index)}_db_subnet_${count.index + 1}"
   environment = var.environment
 }
}

resource "aws_internet_gateway" "igw" {
 vpc_id = aws_vpc.this.id
 depends_on = [
    aws_vpc.this,
    aws_subnet.vpc_public_subnet
  ]

 tags = {
   Name = "${var.vpc_name}_INTERNET_GW"
   environment = var.environment
 }
}

resource "aws_route_table" "public_subnet" {
  count  = length(var.vpc_azs)
  vpc_id = aws_vpc.this.id
  tags = {
       Name = join("-", ["art_public_subnet_az", var.vpc_azs[count.index]])
       environment = var.environment
  }
}


resource "aws_route_table" "app_subnet" {
  count  = length(var.vpc_azs)
  vpc_id = aws_vpc.this.id
  tags   = {
       Name = join("-", ["art_app_subnet_az", var.vpc_azs[count.index]])
       environment = var.environment
  }
}

resource "aws_route_table" "db_subnet" {
  vpc_id = aws_vpc.this.id
  tags   = {
       Name = join("-", ["art_db_subnet_az", "all"])
       environment = var.environment
  }
}

resource "aws_eip" "nat" {
   count  = length(var.vpc_azs)
   domain = "vpc"
}

resource "aws_nat_gateway" "NGW" {
  count         = length(var.vpc_azs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.vpc_public_subnet[count.index].id

  tags = {
    Name = join("-", ["NAT-GW", var.vpc_azs[count.index]])
    environment = var.environment
  }
}

resource "aws_route" "public-internet-igw-route" {
  count                  = length(var.vpc_azs)
  route_table_id         = aws_route_table.public_subnet[count.index].id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
  depends_on = [
    aws_route_table.public_subnet,
    aws_nat_gateway.NGW,
  ]
}

resource "aws_route" "private_nat_gateway_app_subnet" {
  count                  = length(var.vpc_azs)
  route_table_id         = aws_route_table.app_subnet[count.index].id
  nat_gateway_id         = aws_nat_gateway.NGW[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  depends_on = [
    aws_route_table.app_subnet,
    aws_nat_gateway.NGW,
  ]
}

resource "aws_route_table_association" "public_route_table" {
  count = length(var.vpc_public_subnet)
  subnet_id  = aws_subnet.vpc_public_subnet[count.index].id
  route_table_id = aws_route_table.public_subnet[count.index].id
  
  depends_on = [
    aws_subnet.vpc_public_subnet,
    aws_route_table.public_subnet
  ]
}

resource "aws_route_table_association" "app_route_table" {
  count = length(var.vpc_app_subnet)
  subnet_id  = aws_subnet.vpc_app_subnet[count.index].id
  route_table_id = aws_route_table.app_subnet[count.index].id
  
  depends_on = [
    aws_subnet.vpc_app_subnet,
    aws_route_table.app_subnet
  ]
}

resource "aws_route_table_association" "db_route_table" {
  count = length(var.vpc_db_subnet)
  subnet_id  = aws_subnet.vpc_db_subnet[count.index].id
  route_table_id = aws_route_table.db_subnet.id
  
  depends_on = [
    aws_subnet.vpc_db_subnet,
    aws_route_table.db_subnet
  ]
}
