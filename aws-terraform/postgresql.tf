# Create RDS Postgres instance

resource "aws_db_instance" "graph_postgres" {
  engine                 = "postgres"
  engine_version         = var.postgresql_version
  instance_class         = var.postgresql_sku_name
  name                   = var.postgresql_dbname_indexer
  username               = var.postgresql_admin_user
  password               = var.postgresql_admin_password
  skip_final_snapshot    = true
  max_allocated_storage  = var.postgresql_max_alloc_storage
  allocated_storage      = var.postgresql_alloc_storage
  vpc_security_group_ids = [aws_security_group.thegraph-cluster.id]
  db_subnet_group_name   = aws_db_subnet_group.thegraph_db_subnet_group.name
  publicly_accessible    = true

  tags = merge(
    {
      Name        = "TheGraph_DB_Server",
      Project     = "TheGraph"
    }
  )
  depends_on = [
    aws_subnet.thegraph_db_subnets,
    aws_route_table_association.db_subnets
  ]  
}

# Add firewall rules for management acceess to postgres instance

resource "aws_security_group_rule" "thegraph-cluster-ingress-management-PSQL" {
  cidr_blocks       = [local.management-external-cidr]
  description       = "Allow workstation to communicate with the PSQL server"
  from_port         = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.thegraph-cluster.id
  to_port           = 5432
  type              = "ingress"
}

resource "aws_security_group_rule" "thegraph-cluster-ingress-managementIPs-PSQL" {
  cidr_blocks       = var.eks_management_ips
  description       = "Allow management IPs to communicate with the PSQL server"
  from_port         = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.thegraph-cluster.id
  to_port           = 5432
  type              = "ingress"
}

resource "aws_security_group_rule" "thegraph-cluster-ingress-vpc-PSQL" {
  cidr_blocks       = ["10.0.0.0/16"]
  description       = "Allow VPC Network to communicate with the PSQL server"
  from_port         = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.thegraph-cluster.id
  to_port           = 5432
  type              = "ingress"
}


# Create secondary database - indexer service database

provider postgresql {
  host = aws_db_instance.graph_postgres.address
  database = "postgres"
  username = var.postgresql_admin_user
  password = var.postgresql_admin_password
  connect_timeout = 15
}

resource "postgresql_database" "indexer_db" {
  provider = postgresql
  name = var.postgresql_dbname_service
  depends_on = [
    aws_db_instance.graph_postgres,
    aws_internet_gateway.thegraph_internet_gw
  ]
}
