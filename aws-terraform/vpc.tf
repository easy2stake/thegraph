#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#  * NAT Gateways

#### Create VPC ####

resource "aws_vpc" "thegraph_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames    = true

  tags = {
    Name = "thegraph_eks-VPC"
  }

}

#### Create needed subnets ####

resource "aws_subnet" "thegraph_subnets" {
  count = var.vpc_availablitiy_zones

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.thegraph_vpc.id

  tags = map(
    "Name", "thegraph_eks-SUBNETS",
    "kubernetes.io/cluster/${var.eks_cluster_name}", "shared",
  )
}


resource "aws_subnet" "thegraph_gw_subnets" {
  count = var.vpc_availablitiy_zones

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.20${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.thegraph_vpc.id

  tags = {
    Name = "thegraph_eks-GW-SUBNETS",
  }
}

resource "aws_subnet" "thegraph_db_subnets" {
  count = var.vpc_availablitiy_zones
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.10${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.thegraph_vpc.id

  tags = {
    Name = "terraform-eks-db-subnet"
  }
}

resource "aws_db_subnet_group" "thegraph_db_subnet_group" {
  name       = "terraform-eks-db-subnet-group"
  subnet_ids = aws_subnet.thegraph_db_subnets[*].id
}

#### AWS Internet Gateway #####

resource "aws_internet_gateway" "thegraph_internet_gw" {
  vpc_id = aws_vpc.thegraph_vpc.id

  tags = {
    Name = "thegraph-internet-gateway"
  }
}

#### Elastic IPs to be attached to NAT Gateways ####


resource "aws_eip" "eks_network_nat_eip" {
  count = var.vpc_availablitiy_zones
  vpc        = true
  depends_on = [aws_internet_gateway.thegraph_internet_gw]

  tags = {
    Name = "thegraph-network_nat_eip-${count.index}"
  }
}

# Create AWS NAT Gateway  in all AVs (AV redundancy)

resource "aws_nat_gateway" "eks_network_nat_gateway" {
  count = var.vpc_availablitiy_zones
  allocation_id = aws_eip.eks_network_nat_eip.*.id[count.index]
  subnet_id = aws_subnet.thegraph_gw_subnets.*.id[count.index]

  tags = {
    Name = "thegraph-nat-gateway-${count.index}"
  }
  depends_on = [aws_internet_gateway.thegraph_internet_gw]
}

#### Create routing tables ####

resource "aws_route_table" "thegraph_routing_table" {
  vpc_id = aws_vpc.thegraph_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.thegraph_internet_gw.id
  }
}

resource "aws_route_table" "thegraph_routing_table_nat" {
  count = var.vpc_availablitiy_zones
  vpc_id = aws_vpc.thegraph_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks_network_nat_gateway.*.id[count.index]
  }
}

#### Attach subnets to specific route tables ####

resource "aws_route_table_association" "thegraph_routing_table_assoc" {
  count = var.vpc_availablitiy_zones

  subnet_id      = aws_subnet.thegraph_subnets.*.id[count.index]
  route_table_id = aws_route_table.thegraph_routing_table_nat.*.id[count.index]
}

resource "aws_route_table_association" "db_subnets" {
  count = var.vpc_availablitiy_zones

  subnet_id      = aws_subnet.thegraph_db_subnets.*.id[count.index]
  route_table_id = aws_route_table.thegraph_routing_table.id
}

resource "aws_route_table_association" "gw_subnets" {
  count = var.vpc_availablitiy_zones

  subnet_id      = aws_subnet.thegraph_gw_subnets.*.id[count.index]
  route_table_id = aws_route_table.thegraph_routing_table.id
}
