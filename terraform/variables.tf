variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  default     = "banking123"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "banking-cluster"
}
