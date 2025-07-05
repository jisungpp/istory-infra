variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-northeast-2"  # 기본값 설정 (선택사항)
}

variable "vpc_name" {
  description = "name of vpc"
  type        = string
  default     = "dangtong"
}

variable "cluster_name" {
  description = "name of cluster"
  type        = string
  default     = "istory"
}

variable "cluster_version" {
  description = "version of cluster"
  type        = string
  default     = "1.31"
}

variable "environment" {
  description = "Environment name (e.g., dev, stg, prd)"
  type        = string
  default     = "dev"  # 필요한 경우 기본값 설정
}

variable "eks_namespace_roles" {
  description = "Map of namespace names to IAM role configurations"
  type = map(object({
    name               = string
    environment        = string
    additional_policies = list(string)
  }))
  default = {
    "istory-dev" = {
      name               = "istory-dev"
      environment        = "development"
      additional_policies = []
    }
    "istory-prod" = {
      name               = "istory-prod"
      environment        = "production"
      additional_policies = []
    }
  }
}