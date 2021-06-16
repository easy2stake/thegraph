provider "azurerm" {
  features {}
    client_id = var.client_id
    client_secret = var.client_secret
    tenant_id = var.tenant_id
    subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "TheGraph" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.TheGraph.name
  address_space       = "10.1.0.0/16"
  subnet_prefixes     = ["10.1.2.0/24"]
  subnet_names        = ["subnet_aks"]
  depends_on          = [azurerm_resource_group.TheGraph]
}

module "aks" {
  source                           = "Azure/aks/azurerm"
  resource_group_name              = azurerm_resource_group.TheGraph.name
  client_id                        = var.client_id
  client_secret                    = var.client_secret
  kubernetes_version               = var.kubernetes_version
  orchestrator_version             = var.orchestrator_version
  prefix                           = var.prefix
  vnet_subnet_id                   = module.network.vnet_subnets[0]
  os_disk_size_gb                  = var.os_disk_size_gb
  sku_tier                         = var.sku_tier
  network_plugin                   = var.network_plugin
  enable_http_application_routing  = var.enable_http_application_routing
  enable_auto_scaling              = var.enable_auto_scaling
  agents_min_count                 = 1
  agents_max_count                 = 5
  agents_max_pods                  = 100
  agents_count                     = var.agents_count
  agents_size                      = "Standard_D2s_v3"
  agents_pool_name                 = "exnodepool"
  agents_availability_zones        = ["1", "2"]
  agents_type                      = "VirtualMachineScaleSets"
  public_ssh_key                   = var.public_ssh_key
  admin_username                   = var.admin_username

  agents_labels = {
    "nodepool" : "defaultnodepool"
  }

  agents_tags = {
    "Agent" : "defaultnodepoolagent"
  }

  network_policy                 = var.network_policy
  net_profile_dns_service_ip     = "10.0.0.10"
  net_profile_docker_bridge_cidr = "170.10.0.1/16"
  net_profile_service_cidr       = "10.0.0.0/16"

  depends_on = [module.network]
}

resource "azurerm_public_ip" "ingress_ip" {
  name                = "aks_ingressIP"
  resource_group_name = azurerm_resource_group.TheGraph.name
  location            = var.resource_group_location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = "Production"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.aks.host
    client_certificate     = base64decode(module.aks.client_certificate)
    client_key             = base64decode(module.aks.client_key)
    cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
  }
}

resource "helm_release" "ingress" {
  name      = "ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace = "default"
  timeout   = 1800


  set {
    name  = "controller.service.loadBalancerIP"
    value = "azurerm_public_ip.ingress_ip.ip_address"
  }
  set {
    name = "controller.service.annotations.\"service\\.beta\\.kubernetes\\.io/azure-load-balancer-resource-group\""
    value = var.resource_group_name
  }
  set {
    name  = "rbac.create"
    value = "false"
  }
  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }
}

resource "azurerm_postgresql_server" "postgresql-server" {
  name                              = "${var.prefix}-psql-server"
  location                          = var.resource_group_location
  resource_group_name               = azurerm_resource_group.TheGraph.name

  administrator_login               = var.postgresql_admin_user
  administrator_login_password      = var.postgresql_admin_password

  sku_name                          = var.postgresql_sku_name
  version                           = var.postgresql_version

  storage_mb                        = var.postgresql_storage
  auto_grow_enabled                 = true

  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = false
  # ssl_minimal_tls_version_enforced  = "TLS1_2"
  depends_on                        = [azurerm_resource_group.TheGraph]
}

resource "azurerm_postgresql_firewall_rule" "AllowPublicAccess" {
  name                = "AllowPublicAccess"
  resource_group_name = azurerm_resource_group.TheGraph.name
  server_name         = azurerm_postgresql_server.postgresql-server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}

resource "azurerm_postgresql_database" "graphdb" {
  name                = var.postgresql_dbname_indexer
  resource_group_name = azurerm_resource_group.TheGraph.name
  server_name         = azurerm_postgresql_server.postgresql-server.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
  depends_on          = [azurerm_postgresql_server.postgresql-server]
}

resource "azurerm_postgresql_database" "indexer-service" {
  name                = var.postgresql_dbname_service
  resource_group_name = azurerm_resource_group.TheGraph.name
  server_name         = azurerm_postgresql_server.postgresql-server.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
  depends_on          = [azurerm_postgresql_server.postgresql-server]
}

# resource "azurerm_postgresql_database" "vector-node" {
#   name                = var.postgresql_dbname_vector
#   resource_group_name = azurerm_resource_group.TheGraph.name
#   server_name         = azurerm_postgresql_server.postgresql-server.name
#   charset             = "UTF8"
#   collation           = "English_United States.1252"
#   depends_on          = [azurerm_postgresql_server.postgresql-server]
# }
