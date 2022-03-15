provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAZZ5YCGFP5F3S5ZUB"
  secret_key = "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"
}

# policies attached for below role = policy is AmazonEKSClusterPolicy [AWS Service: eks]
resource "aws_eks_cluster" "karthik-new-cluster" {
  name     = "karthik-new-cluster"
  role_arn = "arn:aws:iam::674159014239:role/karthik-cluster-ekscluster-role"

# select the default security group by adding all traffic
  vpc_config {
    subnet_ids         = ["subnet-07fda366893796ef7", "subnet-03db6c34e89ddf970", "subnet-08c282f729e06ddcf"]
    security_group_ids = ["sg-04be1a0d8abcaa043"]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  #    depends_on = [
  #     aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
  #     aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController,
  #   ]
}

#use private subnet for fargate
resource "aws_eks_fargate_profile" "example" {
  cluster_name           = aws_eks_cluster.karthik-new-cluster.name
  fargate_profile_name   = "karthik-new-cluster-fargate"
  pod_execution_role_arn = "arn:aws:iam::674159014239:role/eks-fargate"
  subnet_ids             = ["subnet-0cc76509eaddcc011"]

  selector {
    namespace = "fargate"
  }
}

# policies attached for below role = AmazonEKS_CNI_Policy, AmazonEC2ContainerRegistryReadOnly, AmazonEKSWorkerNodePolicy [AWS Service: ec2]
resource "aws_eks_node_group" "karthik-node-group" {
  cluster_name    = aws_eks_cluster.karthik-new-cluster.name
  node_group_name = "karthik-new-cluster-Ng"
  node_role_arn   = "arn:aws:iam::674159014239:role/karthik-cluster-eks-node-role"
  subnet_ids      = ["subnet-07fda366893796ef7", "subnet-03db6c34e89ddf970", "subnet-08c282f729e06ddcf"]
  ami_type        = "AL2_x86_64"
  capacity_type   = "ON_DEMAND"
  instance_types  = ["t2.medium"]
  disk_size       = 20


  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  #   depends_on = [
  #     aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
  #     aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
  #     aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  #   ]
}
