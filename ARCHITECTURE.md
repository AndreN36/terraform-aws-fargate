# ARQUITETURA FARGATE COM TERRAFORM

## 📐 Diagrama de Componentes

```
┌─────────────────────────────────────────────────────────────────────┐
│                            INTERNET                                  │
└────────────────────────────────┬────────────────────────────────────┘
                                 │
                                 ▼
                    ┌────────────────────────┐
                    │   Application Load     │
                    │    Balancer (ALB)      │
                    │   Port 80/443 (HTTP)   │
                    └────────────┬───────────┘
                                 │
                    ┌────────────┴───────────┐
                    │   Target Group         │
                    │   Port 8080            │
                    └────────────┬───────────┘
                                 │
        ┌────────────────────────┼────────────────────────┐
        │                        │                        │
        ▼                        ▼                        ▼
   ┌─────────┐             ┌─────────┐             ┌─────────┐
   │   Task  │             │   Task  │             │   Task  │
   │    #1   │             │    #2   │             │    #3   │
   │(Fargate)│             │(Fargate)│             │(Fargate)│
   └────┬────┘             └────┬────┘             └────┬────┘
        │                       │                       │
        └───────────────────────┼───────────────────────┘
                                │
                    ┌───────────┴──────────┐
                    │   ECS Cluster        │
                    │ Container Insights   │
                    └───────────┬──────────┘
                                │
                ┌───────────────┼───────────────┐
                │               │               │
                ▼               ▼               ▼
         ┌────────────┐  ┌────────────┐  ┌────────────┐
         │  Private   │  │  Private   │  │  Private   │
         │  Subnet 1  │  │  Subnet 2  │  │  Subnet 3  │
         │  (AZ-a)    │  │  (AZ-b)    │  │  (AZ-c)    │
         └────┬───────┘  └────┬───────┘  └────┬───────┘
              │               │               │
              └───────────────┼───────────────┘
                              │
                    ┌─────────┴──────────┐
                    │   NAT Gateway      │
                    │   (HA com EIPs)    │
                    └─────────┬──────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
   ┌─────────┐           ┌─────────┐           ┌─────────┐
   │  Public │           │  Public │           │  Public │
   │ Subnet1 │           │ Subnet2 │           │ Subnet3 │
   │ (AZ-a)  │           │ (AZ-b)  │           │ (AZ-c)  │
   └────┬────┘           └────┬────┘           └────┬────┘
        │                     │                     │
        └─────────────────────┼─────────────────────┘
                              │
                    ┌─────────▼──────────┐
                    │ Internet Gateway   │
                    │   (IGW)            │
                    └────────────────────┘
```

## 🔐 Componentes de Segurança

```
┌─────────────────────────────────────────────────┐
│  Security Group (ALB)                           │
│  ✓ Inbound: 80 (HTTP), 443 (HTTPS)             │
│  ✓ Outbound: All traffic                       │
└────────────────────┬────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────┐
│  Security Group (ECS Tasks)                     │
│  ✓ Inbound: container_port (de ALB)            │
│  ✓ Outbound: All traffic                       │
│  ✓ Subnets Privadas (sem IP público)           │
└─────────────────────────────────────────────────┘
```

## 🔑 Componentes IAM

```
┌──────────────────────────────────────────────────┐
│ Task Execution Role                              │
│ (arn:aws:iam::*:role/my-app-ecs-task-execution) │
│                                                  │
│ Policies:                                        │
│ • AmazonECSTaskExecutionRolePolicy               │
│ • CloudWatch Logs Create & Put                   │
│ • ECR Get Authorization Token                    │
└──────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────┐
│ Task Role                                        │
│ (arn:aws:iam::*:role/my-app-ecs-task)           │
│                                                  │
│ Policies:                                        │
│ • Customizável (adicione conforme necessário)   │
│ • Ex: S3, DynamoDB, RDS, Secrets Manager        │
└──────────────────────────────────────────────────┘
```

## 📊 Fluxo de Dados

```
1. User Request
   ↓
2. ALB recebe conexão na porta 80
   ↓
3. ALB encaminha para Target Group (porta 8080)
   ↓
4. ECS Service distribui entre Tasks
   ↓
5. Container processa requisição
   ↓
6. Logs enviados para CloudWatch
   ↓
7. Resposta retorna ao usuário
```

## 📈 Auto Scaling

```
ECS Service Auto Scaling:
├── Min Capacity: desired_count
├── Max Capacity: desired_count × 2
└── Policies:
    ├── CPU Target: 70%
    └── Memory Target: 80%
```

## 📝 Network Configuration

```
VPC CIDR: 10.0.0.0/16 (personalizável)
│
├── Subnet Público 1 (AZ-a):  10.0.0.0/18
├── Subnet Público 2 (AZ-b):  10.0.64.0/18
│
├── Subnet Privado 1 (AZ-a):  10.0.128.0/18
└── Subnet Privado 2 (AZ-b):  10.0.192.0/18
```

## 🔄 Deployment Pipeline

```
terraform.tfvars (variáveis)
        ↓
provider.tf (AWS Provider)
        ↓
backend.tf (S3 State)
        ↓
vpc.tf (Networking)
        ↓
security.tf (Security Groups)
        ↓
iam.tf (IAM Roles)
        ↓
ecs.tf (Container Service)
        ↓
alb.tf (Load Balancer)
        ↓
outputs.tf (Resultados)
```

## 🎯 Multi-Ambiente

```
DEV
├── CPU: 256
├── Memory: 512 MB
├── Tasks: 1
├── Logs: 3 dias
└── Enable ALB: true

STAGING
├── CPU: 512
├── Memory: 1024 MB
├── Tasks: 2
├── Logs: 7 dias
└── Enable ALB: true

PROD
├── CPU: 1024+
├── Memory: 2048+ MB
├── Tasks: 3+
├── Logs: 30 dias
└── Enable ALB: true
```

## 💾 State Management

```
S3 Bucket:
└── andre-lab-tf-state-695385418380-us-east-1-an
    └── terraform-fargate.tfstate

Características:
✓ Versionamento habilitado
✓ Acesso restrito por IAM
✓ Criptografia (recomendado habilitar)
```

## 🚀 Scalability

### Horizontal (número de tasks)
```bash
desired_count = 1  → desired_count = 5
# Terraform cria mais tasks automaticamente
```

### Vertical (recursos por task)
```bash
container_cpu    = 256   → container_cpu = 2048
container_memory = 512   → container_memory = 4096
# Redefine task definition com novos recursos
```

### Auto Scaling
```
Métrica: CPU Utilization > 70%  → Aumenta tasks
Métrica: Memory > 80%            → Aumenta tasks
Reduz quando métricas voltam ao normal
```

## 🔍 Observabilidade

### CloudWatch Logs
- Log Group: `/ecs/my-app-dev`
- Stream Prefix: `ecs`
- Retention: Configurável

### Container Insights
- Habilitado no cluster ECS
- Métricas de CPU, memória, network
- Dashboard automático

### Health Checks
- Target Group health check a cada 30s
- Healthy threshold: 2 verificações
- Unhealthy threshold: 2 verificações
- Timeout: 3 segundos

## 📱 Endpoints de Saída

```
ALB DNS: my-app-alb-dev-1234567890.us-east-1.elb.amazonaws.com
HTTP:    http://my-app-alb-dev-1234567890.us-east-1.elb.amazonaws.com
```

## 🎓 Próximos Passos

1. **HTTPS**: Adicionar certificado ACM e listener 443
2. **WAF**: Web Application Firewall para ALB
3. **API Gateway**: Para APIs REST
4. **RDS**: Banco de dados gerenciado
5. **ElastiCache**: Cache distribuído
6. **Secrets Manager**: Gerenciar credenciais
7. **CloudFront**: CDN para distribuição
8. **Route53**: DNS gerenciado
