# Exemplo de terraform.tfvars para Ambiente PROD
app_name    = "my-app"
environment = "prod"
aws_region  = "us-east-1"

# Container - usar imagem do ECR
container_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:latest"
container_port  = 8080

# Recursos aumentados para PROD
container_cpu    = 1024
container_memory = 2048
desired_count    = 3

# Rede
vpc_cidr = "10.0.0.0/16"

# Load Balancer habilitado (essencial para PROD)
enable_load_balancer = true

# Logs com retenção maior
log_retention_days = 30

# Variáveis de ambiente para PROD
container_environment_variables = {
  ENVIRONMENT = "production"
  LOG_LEVEL   = "info"
  DATABASE_URL = "postgresql://user:pass@db-host:5432/prod"
}

tags = {
  Project     = "Terraform-Fargate"
  ManagedBy   = "Terraform"
  Environment = "prod"
  CostCenter  = "prod"
  Backup      = "daily"
  Monitoring  = "enabled"
}
