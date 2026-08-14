# Arquivo de Configuração Terraform para Fargate
# 
# Estrutura:
# - provider.tf: Configuração do provedor AWS
# - backend.tf: Configuração do backend S3 para estado
# - variables.tf: Declaração de todas as variáveis
# - outputs.tf: Declaração de saídas do Terraform
# - vpc.tf: Recursos de VPC, subnets e gateways
# - security.tf: Security groups
# - iam.tf: Roles e políticas IAM
# - ecs.tf: Cluster, task definition, service e autoscaling
# - alb.tf: Application Load Balancer
#
# Como usar:
# 1. Copie terraform.tfvars.example para terraform.tfvars
# 2. Atualize os valores em terraform.tfvars conforme seu ambiente
# 3. Execute: terraform init
# 4. Execute: terraform plan
# 5. Execute: terraform apply

# Todos os recursos criados com este módulo:
# - VPC com subnets públicas e privadas
# - NAT Gateways e Internet Gateway
# - Route tables configuradas
# - Security Groups para ALB e ECS Tasks
# - CloudWatch Log Group
# - ECS Cluster com Container Insights habilitado
# - ECS Task Definition (Fargate)
# - ECS Service com suporte a Application Load Balancer
# - Application Load Balancer (opcional via enable_load_balancer)
# - Target Group
# - Auto Scaling para tasks (CPU e Memória)
# - IAM Roles e Policies
