resource "aws_iam_role" "ec2_role" {
    
  name = "cwave_ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}
# ECR PowerUser 정책 연결
resource "aws_iam_role_policy_attachment" "ecr_poweruser" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}
######################################################################################################################
# IAM Policy 설정
######################################################################################################################
data "http" "iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.6.2/docs/install/iam_policy.json"
}

resource "aws_iam_role_policy" "cwave-eks-controller" {
  name_prefix = "AWSLoadBalancerControllerIAMPolicy"
  role        = module.lb_controller_role.iam_role_name
  policy      = data.http.iam_policy.response_body
}

# EKS Namespace IAM Roles
resource "aws_iam_role" "eks_namespace_role" {
  for_each = var.eks_namespace_roles

  name = "eks-namespace-${each.value.name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = each.value.environment
    ManagedBy   = "terraform"
  }
}

# Attach basic policies to namespace roles
resource "aws_iam_role_policy_attachment" "eks_namespace_policy" {
  for_each = var.eks_namespace_roles

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_namespace_role[each.key].name
}

# Attach additional policies if specified
resource "aws_iam_role_policy_attachment" "eks_namespace_additional_policies" {
  for_each = {
    for policy in flatten([
      for ns_key, ns in var.eks_namespace_roles : [
        for policy in ns.additional_policies : {
          ns_key = ns_key
          policy = policy
        }
      ]
    ]) : "${policy.ns_key}-${policy.policy}" => policy
  }

  policy_arn = each.value.policy
  role       = aws_iam_role.eks_namespace_role[each.value.ns_key].name
}