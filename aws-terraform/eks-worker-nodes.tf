#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes

resource "aws_iam_role" "thegraph-node" {
  name = "terraform-eks-thegraph-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "thegraph-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.thegraph-node.name
}

resource "aws_iam_role_policy_attachment" "thegraph-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.thegraph-node.name
}

resource "aws_iam_role_policy_attachment" "thegraph-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.thegraph-node.name
}

resource "aws_eks_node_group" "thegraph_node_group" {
  cluster_name    = aws_eks_cluster.thegraph.name
  node_group_name = "thegraph_node_group"
  node_role_arn   = aws_iam_role.thegraph-node.arn
  subnet_ids      = aws_subnet.thegraph_subnets[*].id
  instance_types  = var.instance_types

  scaling_config {
    desired_size = var.eks_node_group_scaling_desired
    max_size     = var.eks_node_group_scaling_max
    min_size     = var.eks_node_group_scaling_min
  }

  tags = {
    Name = "thegraph-cluster-worker-group"
  }

  depends_on = [
    aws_iam_role_policy_attachment.thegraph-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.thegraph-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.thegraph-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}
