#
# Outputs
#

locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH


apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.thegraph-node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH

  kubeconfig = <<KUBECONFIG


apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.thegraph.endpoint}
    certificate-authority-data: ${aws_eks_cluster.thegraph.certificate_authority[0].data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.eks_cluster_name}"
KUBECONFIG

Public_IPS = <<IPS

IPs assigned to NAT Gateways that should be added in specific firewalls that protects ETH endpoints, other resources:
${aws_nat_gateway.eks_network_nat_gateway.0.public_ip}
${aws_nat_gateway.eks_network_nat_gateway.1.public_ip}

Postgresql DB instance:
${aws_db_instance.graph_postgres.address}
IPS
}



output "config_map_aws_auth" {
  value = local.config_map_aws_auth
}

output "kubeconfig" {
  value = local.kubeconfig
}

output "Public_IPS" {
  value = local.Public_IPS
}