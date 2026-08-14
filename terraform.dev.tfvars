# Exemplo de terraform.tfvars para Ambiente DEV
app_name    = "my-app"
environment = "dev"
aws_region  = "us-east-1"

# Container - usar imagem public (nginx) para teste
container_image = "nginx:latest"
container_port  = 80

# Recursos reduzidos para DEV
container_cpu    = 256
container_memory = 512
desired_count    = 1

# Rede
vpc_cidr = "10.0.0.0/16"

# Load Balancer habilitado
enable_load_balancer = true

# Logs com retenção reduzida
log_retention_days = 3

# Variáveis de ambiente
container_environment_variables = {
  ENVIRONMENT = "development"
  LOG_LEVEL   = "debug"
}

tags = {
  Project     = "Terraform-Fargate"
  ManagedBy   = "Terraform"
  Environment = "dev"
  CostCenter  = "dev"
}
