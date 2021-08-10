# NGINX Ingress controller used for publishing services deployment

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.thegraph.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.thegraph.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.thegraph.name]
      command     = "aws"
    }
  }
}

resource "helm_release" "ingress" {

  repository = var.nginx_ingress_helm_repo_url
  chart      = var.nginx_ingress_helm_chart_name
  version    = var.nginx_ingress_helm_chart_version

  create_namespace = var.k8s_create_namespace
  namespace        = var.k8s_namespace
  name             = var.nginx_ingress_helm_release_name

  set {
    name = "controller.service.annotations.\"service\\.beta\\.kubernetes\\.io/aws-load-balancer-type\""
    value = "nlb"
  }

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  depends_on = [
    aws_eks_cluster.thegraph, 
    aws_eks_node_group.thegraph_node_group,
    aws_internet_gateway.thegraph_internet_gw
  ]
}