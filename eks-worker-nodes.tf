resource "aws_iam_role" "demo-node" {
  name = "terraform-eks-node"
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

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.demo-node.name
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.demo-node.name
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.demo-node.name
}

resource "tls_private_key" "key" {
  algorithm   =  "RSA"
  rsa_bits    =  4096
}

resource "local_file" "key" {
  depends_on = [
    tls_private_key.key
  ]
  content         =  tls_private_key.key.private_key_pem
  filename        =  "webserver.pem"
}

resource "aws_key_pair" "key" {
   depends_on = [
    local_file.key
  ]
  key_name   = "eks-nodes"
  public_key = tls_private_key.key.public_key_openssh
}

resource "aws_eks_node_group" "demo" {
  cluster_name    = aws_eks_cluster.demo.name
  node_group_name = "demo"
  node_role_arn   = aws_iam_role.demo-node.arn
  subnet_ids      = aws_subnet.demo[*].id
  instance_types  = ["t2.medium"]
  disk_size       = 10
  remote_access {
    ec2_ssh_key = aws_key_pair.key.key_name
  }
  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 1
  }
  depends_on = [
    aws_key_pair.key,
    aws_iam_role_policy_attachment.demo-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.demo-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.demo-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}
