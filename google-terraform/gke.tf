# GKE cluster

# Get latest K8s version for configured region

data "google_container_engine_versions" "region_version" {
  project        = var.project_id
  provider       = google-beta
  location       = var.region
  version_prefix = "1.20."
}


resource "google_container_cluster" "primary" {
  name                     = "${var.project_id}-gke"
  location                 = var.region
  min_master_version       = data.google_container_engine_versions.region_version.latest_node_version
  remove_default_node_pool = true
  node_locations           = var.gke_node_locations
  initial_node_count       = 1
  private_cluster_config {
    master_ipv4_cidr_block  = "172.16.0.0/28"
    enable_private_endpoint = false
    enable_private_nodes    = true

    # If public access to k8s endpoint is needed:
    # master_global_access_config {
    #   enabled = true
    # }
  }

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  # If global public access was disabled (see above), we define a list of management IP ranges
  master_authorized_networks_config {
    cidr_blocks {
        cidr_block = local.management-external-cidr
        display_name = "Local PC external IP address"
    }

    cidr_blocks {
        cidr_block = var.gke_management_ips
        display_name = "Other Mgmt CIDR IP Block defined in vars file"
    }
  }

  ip_allocation_policy {
  }
  depends_on = [ 
    google_compute_network.vpc,
    google_sql_database_instance.graph
   ]
}

#  Node Pool to be used by GKE cluster

resource "google_container_node_pool" "primary_nodes" {
  name           = "${google_container_cluster.primary.name}-node-pool"
  location       = var.region
  cluster        = google_container_cluster.primary.name
  node_count     = var.gke_num_nodes
  version        = data.google_container_engine_versions.region_version.latest_node_version

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.project_id
    }

    machine_type = var.gke_node_pool_machine_type
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }
  depends_on = [ google_container_cluster.primary ]
}



