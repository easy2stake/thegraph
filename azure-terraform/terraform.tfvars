# The data below can be changed depending on the needs.
# Besides credentials, all variables are already set for a small k8s cluster.

#==================#
# Azure connection #
#==================#

client_id = "YOUR_AAD_APPLICATION_CLIENT_ID"
client_secret = "YOUR_AAD_APPLICATION_CLIENT_SECRET"
tenant_id = "YOUR_AAD_TENANT_ID"
subscription_id = "YOUR_AAD_SUBSCRIPTION_ID"

#====================#
# Azure AKS TheGraph #
#====================#

resource_group_name = "RG-graphprotocol-aks"
resource_group_location = "westeurope"

public_ssh_key = "RSA_SSH_PUBKEY_FOR_DIRECT_NODE_ACCESS"
prefix = "graph"
kubernetes_version = "1.20.7"
orchestrator_version = "1.20.7"
enable_auto_scaling = true
network_plugin = "azure"
agents_size = "Standard_D2s_v3"
os_disk_size_gb = 50
network_policy = "azure"
enable_http_application_routing = false

#=====================#
# Azure PSQL TheGraph #
#=====================#

postgresql_admin_user = "graphpsql"
postgresql_admin_password = "P@SsPsQL965#r00t"
postgresql_version = "11"
postgresql_sku_name = "GP_Gen5_4"
postgresql_storage = "5120"
postgresql_dbname_indexer = "graph"
postgresql_dbname_service = "indexer-service"
postgresql_dbname_vector = "vector"
