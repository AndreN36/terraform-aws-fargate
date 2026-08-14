# GUIA DE BOAS PRÁTICAS - FARGATE COM TERRAFORM

## 📋 Estrutura do Projeto

```
fargate/
├── provider.tf              # Configuração do provider AWS
├── backend.tf               # Backend S3 para estado
├── variables.tf             # Declaração de variáveis
├── outputs.tf               # Outputs do Terraform
├── vpc.tf                   # Recursos de VPC
├── security.tf              # Security Groups
├── iam.tf                   # Roles e Policies IAM
├── ecs.tf                   # ECS Cluster, Service, Task Definition
├── alb.tf                   # Application Load Balancer
├── terraform.tfvars.example # Exemplo de variáveis
├── terraform.dev.tfvars     # Configuração para DEV
├── terraform.prod.tfvars    # Configuração para PROD
└── README.md                # Este arquivo
```

## 🚀 Quick Start

### 1. Preparação Inicial
```bash
cd fargate/

# Copiar arquivo de variáveis para seu ambiente
cp terraform.tfvars.example terraform.tfvars

# Editar com seus valores
nano terraform.tfvars
```

### 2. Inicializar Terraform
```bash
terraform init
```

### 3. Validar Configuração
```bash
terraform validate
terraform fmt -recursive
terraform plan
```

### 4. Aplicar Configuração
```bash
terraform apply

# Para ambientes específicos:
terraform apply -var-file="terraform.dev.tfvars"
terraform apply -var-file="terraform.prod.tfvars"
```

## 📦 Recursos Criados

### Rede (VPC)
- VPC com CIDR personalizável
- 2 Subnets Públicas (diferentes AZs)
- 2 Subnets Privadas (diferentes AZs)
- Internet Gateway
- 2 NAT Gateways (para alta disponibilidade)
- Route Tables públicas e privadas

### Segurança
- Security Group para ALB
- Security Group para ECS Tasks
- Regras configuradas automaticamente

### IAM
- Task Execution Role (acesso a ECR, CloudWatch)
- Task Role (pode ser expandida com permissões específicas)

### ECS
- Cluster com Container Insights habilitado
- Task Definition (Fargate)
- Service com integração ALB
- Auto Scaling baseado em CPU/Memória

### Load Balancing
- Application Load Balancer
- Target Group
- Listener HTTP:80

### Observabilidade
- CloudWatch Log Group com retenção configurável

## 🔧 Variáveis Principais

### Identidade
- `app_name`: Nome da aplicação
- `environment`: dev, staging, prod
- `aws_region`: Região AWS

### Container
- `container_image`: URL da imagem Docker (ECR ou público)
- `container_port`: Porta do container
- `container_cpu`: 256, 512, 1024, 2048, 4096
- `container_memory`: Valores válidos do Fargate
- `desired_count`: Número de tasks desejadas

### Load Balancer
- `enable_load_balancer`: true/false

### Logging
- `log_retention_days`: Dias de retenção

## 💡 Boas Práticas Implementadas

✅ **Modularidade**: Cada componente em arquivo separado
✅ **Variáveis com Validação**: Valores aceitos validados
✅ **Naming Convention**: Nomes descritivos com prefixo app
✅ **Tags Padrão**: Aplicadas a todos os recursos
✅ **Alta Disponibilidade**: Multi-AZ para subnets e NAT
✅ **Security Groups**: Isolamento de tráfego
✅ **Auto Scaling**: Escalabilidade automática
✅ **Logging Centralizado**: CloudWatch Logs
✅ **State Management**: Backend S3 com versionamento
✅ **Container Insights**: Monitoramento habilitado

## 📝 Customizações Comuns

### Usar Imagem Custom do ECR
```hcl
container_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:v1.0.0"
```

### Adicionar Variáveis de Ambiente
```hcl
container_environment_variables = {
  DATABASE_HOST = "mydb.example.com"
  API_KEY = "secret-key"
}
```

### Aumentar Capacidade
```hcl
container_cpu    = 2048
container_memory = 4096
desired_count    = 5
```

### Desabilitar Load Balancer
```hcl
enable_load_balancer = false
```

### Adicionar Secrets via AWS Secrets Manager
Edite o arquivo `ecs.tf` e adicione em `container_definitions`:
```hcl
secrets = [
  {
    name      = "DB_PASSWORD"
    valueFrom = "arn:aws:secretsmanager:region:account:secret:name"
  }
]
```

## 🔐 Segurança

- Subnets privadas para tasks (sem IP público direto)
- ALB em subnets públicas
- Security groups restrictivos
- IAM roles com least privilege
- Logs centralizados para auditoria

## 🔄 Atualizações de Imagem

Para atualizar a imagem do container:
```bash
# Edite terraform.tfvars
container_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:v2.0.0"

# Aplique
terraform apply -var-file="terraform.tfvars"
```

## 🗑️ Destruir Recursos

```bash
terraform destroy
# ou para ambiente específico:
terraform destroy -var-file="terraform.prod.tfvars"
```

## 📊 Monitorar Logs

```bash
# CloudWatch Logs
aws logs tail /ecs/my-app-dev --follow

# ECS Service
aws ecs describe-services --cluster my-app-cluster-dev \
  --services my-app-service-dev --region us-east-1
```

## 🆘 Troubleshooting

### Erro: InvalidParameterException: Memory is not valid for CPU
Verifique combinações válidas em: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ecs-taskdefinition.html

### Tasks não iniciam
- Verifique logs: `aws logs tail /ecs/my-app-dev --follow`
- Valide security group rules
- Confirme imagem está acessível

### Load Balancer retorna 502
- Verifique health check em Target Group
- Confirme porta e protocolo corretos
- Validar security group permite tráfego

## 📚 Referências

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Fargate Task CPU/Memory](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ecs-taskdefinition.html)
- [ECS Task Definition](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html)
- [AWS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_best_practices.html)
