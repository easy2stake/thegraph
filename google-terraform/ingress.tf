# NGINX Ingress controller used for publishing services deployment

#Add firewall rule needed by Master nodes to access worker nodes on port 8443:

resource "google_compute_firewall" "ingress_web_hook" {
  name    = "ingress-web-hook"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["8443"]
  }

  target_tags   = ["gke-node"]
  source_ranges = ["172.16.0.0/28"]
}

data "google_client_config" "gcloud" {}

provider "helm" {
  kubernetes {
   host                   = google_container_cluster.primary.endpoint
   token                  = data.google_client_config.gcloud.access_token
   cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
  }
}

#Create ingress using helm provider

resource "helm_release" "ingress" {

  repository = var.nginx_ingress_helm_repo_url
  chart      = var.nginx_ingress_helm_chart_name
  version    = var.nginx_ingress_helm_chart_version

  create_namespace = var.k8s_create_namespace
  namespace        = var.k8s_namespace
  name             = var.nginx_ingress_helm_release_name


  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  depends_on = [
    google_container_cluster.primary,
    google_container_node_pool.primary_nodes
  ]
} 

