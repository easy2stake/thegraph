#===================#
# AWS EKS Variables #
#===================#

variable eks_management_ips  {
  description = "Array of CIDR IP blocks that can access PSQL server & EKS API beside local public IP from which terraform was ran"
}

variable "eks_cluster_name" {
  type    = string
  description = "EKS Cluster name"
}

variable "vpc_availablitiy_zones" {
  description = "Number of availability zones to use"
}

variable "instance_types" {
  description = "Instance types to be used by EKS worker group"
}

variable "aws_region" {
  default = "us-west-2"
}

variable "eks_node_group_scaling_desired" {
  description = "Number of worker nodes to be started"
}
variable "eks_node_group_scaling_min" {
  description = "Minimum number of worker nodes"
}
variable "eks_node_group_scaling_max" {
  description = "Maximum number of worker nodes"
}

variable "eks_version" {
  description = "Kubernetes cluster version"
}

#===================#
# AWS PSQL TheGraph #
#===================#

variable "postgresql_admin_user" {
  description = "Postgresql admin user - will be used for managing Postgres and accessing databases from TheGraph componentes"
}
variable "postgresql_admin_password" {
  description = "Postgresql admin user password"
}
variable "postgresql_version" {
  description = "Postgresql version to be used. Please check Azure supported version in your region & TheGraph limitations"
  default = "12.7"
}
variable "postgresql_sku_name" {
  description = "Postgresql AWS RDS size. Minimum required size for TheGraph is db.t3.xlarge"
  default = "db.t3.xlarge"
}
variable "postgresql_alloc_storage" {
  description = "Postgresql allocated space for TheGraph project. Can be increased anytime. Default 50GB"
  default = "50"
}

variable "postgresql_max_alloc_storage" {
  description = "Postgresql max allocation storage for TheGraph project. Can be increased anytime."
}

variable "postgresql_dbname_indexer" {
  description = "TheGraph Query"
  default = "graph"
}

variable "postgresql_dbname_service" {
  description = "TheGraph indexer database"
  default = "indexer-service"
}

#=============#
# K8s Ingress #
#=============#

# Helm

variable "nginx_ingress_helm_chart_name" {
  type        = string
  default     = "ingress-nginx"
  description = "Helm chart name to be installed"
}

variable "nginx_ingress_helm_chart_version" {
  type        = string
  description = "Version of the Helm chart"
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
