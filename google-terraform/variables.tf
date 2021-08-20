# GDP

variable "project_id" {
  description = "Google Cloud Platform project ID"
}

variable "region" {
  description = "Used GCP region for deploying K8s cluster"
}


# GKE

variable "gke_num_nodes" {
  default     = 1
  description = "number of gke nodes"
}

variable "gke_node_pool_machine_type" {
  default = "n2d-highmem-2"
  description = "VM Instance type to be used as worker nodes"
}

variable "gke_management_ips" {
  description = "Public IP addresses that will be able to connect to public K8s endpoint. Please note that local public IP of workstation from which terraform is ran will be added automatically"
}

variable "gke_node_locations" {
  description = "List of region zones to be used for deploying GKE Cluster worker nodes"
}

# Helm & Ingress

variable "nginx_ingress_helm_chart_name" {
  type        = string
  default     = "ingress-nginx"
  description = "Helm chart name to be installed"
}

variable "nginx_ingress_helm_chart_version" {
  type        = string
  description = "Version of the Helm chart"
  default     = "3.35.0"
}

variable "nginx_ingress_helm_release_name" {
  type        = string
  default     = "ingress-nginx"
  description = "Helm release name"
}

variable "nginx_ingress_helm_repo_url" {
  type        = string
  default     = "https://kubernetes.github.io/ingress-nginx"
  description = "Helm repository"
}

# K8s

variable "k8s_create_namespace" {
  type        = bool
  default     = true
  description = "Whether to create k8s namespace with name defined by `k8s_namespace`"
}

variable "k8s_namespace" {
  type        = string
  default     = "ingress-controller"
  description = "The K8s namespace in which the ingress-nginx has been created"
}

# Database

variable "postgresql_database_tier" {
  type        = string
  default     = "db-custom-8-30720"
  description = "The type of machine to use for the database"
}

variable "postgresql_admin_user" {
  description = "Postgresql admin user - will be used for managing Postgres and accessing databases from TheGraph componentes"
}
variable "postgresql_admin_password" {
  description = "Postgresql admin user password"
}

variable "postgresql_dbname_indexer" {
  description = "TheGraph Query"
  default = "graph"
}

variable "postgresql_dbname_service" {
  description = "TheGraph indexer database"
  default = "indexer-service"
}

variable "postgresql_version" {
  default     = "POSTGRES_12"
  description = "Postgresql version"  
}
