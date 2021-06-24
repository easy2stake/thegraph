#==================#
# Azure connection #
#==================#

variable "client_id" {
  description = "Azure Client AD"
}

variable "client_secret" {
  description = "Azure Client Secret"
}

variable "tenant_id" {
  description = "Azure Tenant ID"
}

variable "subscription_id" {
  description = "Azure Subscription ID"
}

#====================#
# Azure AKS TheGraph #
#====================#

variable "resource_group_name" {
  description = "Azure Resource Group Name in which ALL resources will be created"
}

variable "resource_group_location" {
  description = "Azure Resource Group Name location in which ALL resources will be created"
}

variable "prefix" {
  description = "The prefix for the resources created in the specified Azure Resource Group"
  type        = string
}

variable "public_ssh_key" {
	description = "SSH key for AKS node administration"
}

variable "sku_tier" {
  description = "The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid"
  type        = string
  default     = "Paid"
}

variable "admin_username" {
  default     = "azureuser"
  description = "The username of the local administrator to be created on the Kubernetes cluster"
  type        = string
}

variable "enable_http_application_routing" {
  description = "Enable HTTP Application Routing Addon (forces recreation). Needed for ingress configuration of TheGraph project"
  type        = bool
  default     = false
}

variable "enable_auto_scaling" {
  description = "Enable node pool autoscaling"
  type        = bool
}

variable "network_policy" {
  description = " (Optional) Sets up network policy to be used with Azure CNI. Network policy allows us to control the traffic flow between pods. Currently supported values are calico and azure. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "network_plugin" {
  description = "Network plugin to use for networking."
  type        = string
  default     = "kubenet"
}

variable "agents_size" {
  default     = "Standard_D2s_v3"
  description = "The default virtual machine size for the Kubernetes agents. Please use bigger sizes for production purposes"
  type        = string
}

variable "agents_count" {
  description = "The number of Agents that should exist in the Agent Pool. Please set `agents_count` `null` while `enable_auto_scaling` is `true` to avoid possible `agents_count` changes."
  type        = number
  default     = null
}

variable "os_disk_size_gb" {
  description = "Disk size of nodes in GBs."
  type        = number
  default     = 50
}

variable "kubernetes_version" {
  description = "Specify which Kubernetes release to use. The default used is the latest Kubernetes version available in the region"
  type        = string
  default     = null
}

variable "orchestrator_version" {
  description = "Specify which Kubernetes release to use for the orchestration layer. The default used is the latest Kubernetes version available in the region"
  type        = string
  default     = null
}

#=====================#
# Azure PSQL TheGraph #
#=====================#

variable "postgresql_admin_user" {
	description = "Postgresql admin user - will be used for managing Postgres and accessing databases from TheGraph componentes"
}
variable "postgresql_admin_password" {
	description = "Postgresql admin user password"
}
variable "postgresql_version" {
	description = "Postgresql version to be used. Please check Azure supported version in your region & TheGraph limitations"
  default = "11"
}
variable "postgresql_sku_name" {
	description = "Postgresql server size. Minimum required version for TheGraph is GP_Gen5_4"
  default = "GP_Gen5_4"
}
variable "postgresql_storage" {
	description = "Postgresql allocated space for TheGraph project. Can be increased anytime. Default 256GB"
  default = "262144"
}

variable "postgresql_dbname_query" {
  description = "TheGraph Query"
	default = "graph"
}

variable "postgresql_dbname_indexer" {
  description = "TheGraph indexer database"
  default = "indexer-service"
}

variable "postgresql_dbname_service" {
  description = "TheGraph vector database"
  default = "indexer-service"
}
