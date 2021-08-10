# Aws 

vpc_availablitiy_zones = 2
aws_region = "us-west-2"

# EKS variables

eks_management_ips = ["1.1.1.1/32", "2.2.2.2/32"]
eks_cluster_name = "theGraph-EKS-CLS"
instance_types = ["t3.medium"]
eks_node_group_scaling_desired = 2
eks_node_group_scaling_min = 1
eks_node_group_scaling_max = 5
eks_version = 1.21


# Postgres variables

postgresql_dbname_indexer = "graph"
postgresql_dbname_service = "indexer-service"
postgresql_admin_user = "graphpsql"
postgresql_admin_password = "PaSsPsQL965#r00t"
postgresql_alloc_storage = 50
postgresql_max_alloc_storage = 500

# K8s
nginx_ingress_helm_chart_version = "3.35.0"
