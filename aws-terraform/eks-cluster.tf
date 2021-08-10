#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster

resource "aws_iam_role" "thegraph-cluster" {
  name = "terraform-eks-thegraph-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "thegraph-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.thegraph-cluster.name
}

resource "aws_iam_role_policy_attachment" "thegraph-cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.thegraph-cluster.name
}

resource "aws_security_group" "thegraph-cluster" {
  name        = "terraform-eks-thegraph-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.thegraph_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "thegraph-cluster-SG"
  }
}

resource "aws_security_group_rule" "thegraph-cluster-ingress-management-https" {
  cidr_blocks       = [local.management-external-cidr]
  description       = "Allow management workstation from which terraform was ran to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.thegraph-cluster.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "thegraph-cluster-ingress-managementIPs-https" {
  cidr_blocks       = var.eks_management_ips
  description       = "Allow management IPs to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.thegraph-cluster.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_eks_cluster" "thegraph" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.thegraph-cluster.arn
  version  = var.eks_version

  vpc_config {
    security_group_ids = [aws_security_group.thegraph-cluster.id]
    subnet_ids         = aws_subnet.thegraph_subnets[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.thegraph-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.thegraph-cluster-AmazonEKSVPCResourceController,
  ]
}


data "aws_eks_cluster" "thegraph" {
  name = var.eks_cluster_name
  depends_on = [aws_eks_cluster.thegraph]
}

data "aws_eks_cluster_auth" "thegraph" {
  name = var.eks_cluster_name
  depends_on = [aws_eks_cluster.thegraph]
}
