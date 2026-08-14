variable "app_name" {
  description = "Nome da aplicação"
  type        = string
  default     = "my-app"
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Ambiente deve ser dev, staging ou prod."
  }
}

variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "container_port" {
  description = "Porta do container"
  type        = number
  default     = 8080
}

variable "container_image" {
  description = "URL da imagem Docker (ECR)"
  type        = string
}

variable "container_cpu" {
  description = "CPU em unidades Fargate (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 256

  validation {
    condition = contains([256, 512, 1024, 2048, 4096], var.container_cpu)
    error_message = "CPU deve ser um valor válido do Fargate."
  }
}

variable "container_memory" {
  description = "Memória em MB (Fargate)"
  type        = number
  default     = 512

  validation {
    condition = contains([512, 1024, 2048, 3072, 4096, 5120, 6144, 7168, 8192], var.container_memory)
    error_message = "Memória deve ser um valor válido do Fargate."
  }
}

variable "desired_count" {
  description = "Número desejado de tasks"
  type        = number
  default     = 1

  validation {
    condition     = var.desired_count > 0
    error_message = "desired_count deve ser maior que 0."
  }
}

variable "vpc_cidr" {
  description = "CIDR da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "container_environment_variables" {
  description = "Variáveis de ambiente para o container"
  type        = map(string)
  default     = {}
}

variable "enable_load_balancer" {
  description = "Habilitar Application Load Balancer"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Dias de retenção de logs no CloudWatch"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags padrão para todos os recursos"
  type        = map(string)
  default     = {}
}
