# GDP
project_id = "the-graph-322812"
region     = "us-central1"

# GKE
gke_management_ips = "1.1.1.1/32"
gke_node_pool_machine_type = "n2d-highmem-2"
gke_node_locations = ["us-central1-a", "us-central1-b", "us-central1-c"]

# Helm & Ingress
nginx_ingress_helm_chart_version = "3.35.0"


postgresql_dbname_indexer = "graph"
postgresql_dbname_service = "indexer-service"
postgresql_admin_user = "graphpsql"
postgresql_admin_password = "PaSsPsQL965#r00t"
postgresql_version = "POSTGRES_12"
