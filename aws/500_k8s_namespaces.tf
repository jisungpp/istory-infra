# Kubernetes Provider Configuration
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# Istory Development Namespace
resource "kubernetes_namespace" "istory_dev" {
  metadata {
    name = "istory-dev"
    
    labels = {
      environment = "development"
      app         = "istory"
      managed-by  = "terraform"
    }
    
    annotations = {
      "creator"                = "terraform"
      "team"                   = "devops"
      "environment-type"       = "development"
      "iam.amazonaws.com/role" = aws_iam_role.eks_namespace_role["istory-dev"].arn
    }
  }
}

# Resource Quota for Dev Namespace
resource "kubernetes_resource_quota" "istory_dev_quota" {
  metadata {
    name      = "istory-dev-quota"
    namespace = kubernetes_namespace.istory_dev.metadata[0].name
  }

  spec {
    hard = {
      "requests.cpu"    = "4"
      "requests.memory" = "8Gi"
      "limits.cpu"      = "8"
      "limits.memory"   = "16Gi"
      "pods"           = "20"
    }
  }
}

# LimitRange for Dev Namespace
resource "kubernetes_limit_range" "istory_dev_limits" {
  metadata {
    name      = "istory-dev-limits"
    namespace = kubernetes_namespace.istory_dev.metadata[0].name
  }

  spec {
    limit {
      type = "Container"
      default = {
        cpu    = "500m"
        memory = "512Mi"
      }
      default_request = {
        cpu    = "100m"
        memory = "256Mi"
      }
      max = {
        cpu    = "2"
        memory = "2Gi"
      }
      min = {
        cpu    = "50m"
        memory = "64Mi"
      }
    }
  }
}

# Istory Production Namespace
resource "kubernetes_namespace" "istory_prod" {
  metadata {
    name = "istory-prod"
    
    labels = {
      environment = "production"
      app         = "istory"
      managed-by  = "terraform"
    }
    
    annotations = {
      "creator"                = "terraform"
      "team"                   = "devops"
      "environment-type"       = "production"
      "iam.amazonaws.com/role" = aws_iam_role.eks_namespace_role["istory-prod"].arn
    }
  }
}

# Resource Quota for Prod Namespace
resource "kubernetes_resource_quota" "istory_prod_quota" {
  metadata {
    name      = "istory-prod-quota"
    namespace = kubernetes_namespace.istory_prod.metadata[0].name
  }

  spec {
    hard = {
      "requests.cpu"    = "8"
      "requests.memory" = "16Gi"
      "limits.cpu"      = "16"
      "limits.memory"   = "32Gi"
      "pods"           = "40"
    }
  }
}

# LimitRange for Prod Namespace
resource "kubernetes_limit_range" "istory_prod_limits" {
  metadata {
    name      = "istory-prod-limits"
    namespace = kubernetes_namespace.istory_prod.metadata[0].name
  }

  spec {
    limit {
      type = "Container"
      default = {
        cpu    = "1"
        memory = "1Gi"
      }
      default_request = {
        cpu    = "500m"
        memory = "512Mi"
      }
      max = {
        cpu    = "4"
        memory = "4Gi"
      }
      min = {
        cpu    = "100m"
        memory = "128Mi"
      }
    }
  }
} 