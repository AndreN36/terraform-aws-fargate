# Terraform AWS ECS Fargate

Infraestrutura como código para provisionamento de uma aplicação containerizada utilizando **Amazon ECS com AWS Fargate**, incluindo networking, load balancing, observabilidade, segurança e Auto Scaling.

## 🏗️ Arquitetura

Este projeto provisiona uma infraestrutura AWS composta por:

* **VPC** com Public e Private Subnets
* **Internet Gateway**
* **NAT Gateways**
* **Route Tables**
* **Security Groups**
* **Amazon ECS Cluster**
* **ECS Task Definition**
* **ECS Service utilizando Fargate**
* **Application Load Balancer (ALB)**
* **Target Group**
* **CloudWatch Logs**
* **ECS Container Insights**
* **Application Auto Scaling**
* **IAM Roles e Policies**

O Application Load Balancer pode ser habilitado ou desabilitado através da variável `enable_load_balancer`.

---

## 📁 Estrutura do projeto

```text
.
├── provider.tf
├── backend.tf
├── variables.tf
├── outputs.tf
├── vpc.tf
├── security.tf
├── iam.tf
├── ecs.tf
├── alb.tf
├── terraform.tfvars.example
└── README.md
```

| Arquivo        | Descrição                                                    |
| -------------- | ------------------------------------------------------------ |
| `provider.tf`  | Configuração do AWS Provider                                 |
| `backend.tf`   | Configuração do Remote State utilizando Amazon S3            |
| `variables.tf` | Declaração das variáveis utilizadas pelo projeto             |
| `outputs.tf`   | Outputs dos recursos provisionados                           |
| `vpc.tf`       | VPC, Subnets, Internet Gateway, NAT Gateways e Route Tables  |
| `security.tf`  | Security Groups utilizados pelo ALB e ECS Tasks              |
| `iam.tf`       | IAM Roles e Policies necessárias para execução das ECS Tasks |
| `ecs.tf`       | ECS Cluster, Task Definition, Service e Auto Scaling         |
| `alb.tf`       | Application Load Balancer, Listener e Target Group           |

---

## ⚙️ Pré-requisitos

Antes de executar o projeto, certifique-se de possuir:

* Terraform instalado
* AWS CLI instalada e configurada
* Credenciais AWS válidas
* Permissões suficientes para criação dos recursos
* Bucket S3 previamente criado para utilização como Terraform Remote State

Verifique a autenticação AWS:

```bash
aws sts get-caller-identity
```

---

## 🚀 Como utilizar

### 1. Clone o repositório

```bash
git clone <repository-url>
cd <repository-name>
```

### 2. Configure as variáveis

Copie o arquivo de exemplo:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edite `terraform.tfvars` de acordo com o ambiente:

```hcl
aws_region = "us-east-1"

environment = "dev"

enable_load_balancer = true
```

> O arquivo `terraform.tfvars` pode conter configurações específicas do ambiente e não deve ser versionado caso possua informações sensíveis.

### 3. Inicialize o Terraform

```bash
terraform init
```

### 4. Valide a configuração

```bash
terraform validate
```

### 5. Revise o plano de execução

```bash
terraform plan
```

Para salvar o plano:

```bash
terraform plan -out=tfplan
```

### 6. Provisionar a infraestrutura

```bash
terraform apply
```

Ou utilizando o plano previamente criado:

```bash
terraform apply tfplan
```

---

## 📈 Auto Scaling

O ECS Service possui suporte a **Application Auto Scaling**, permitindo ajuste automático da quantidade de Tasks baseado em métricas do Amazon CloudWatch.

As políticas disponíveis utilizam:

* CPU Utilization
* Memory Utilization

Isso permite que o serviço aumente ou reduza automaticamente sua capacidade de acordo com a carga da aplicação.

---

## 📊 Observabilidade

O projeto habilita recursos de observabilidade através de:

**CloudWatch Logs**

Centraliza os logs gerados pelos containers executados nas ECS Tasks.

**Container Insights**

Permite acompanhar métricas relacionadas ao ECS Cluster e às Tasks, incluindo utilização de CPU e memória.

---

## 🔐 Segurança

A infraestrutura utiliza Security Groups separados para o ALB e para as ECS Tasks.

Fluxo esperado:

```text
Internet
   │
   ▼
Application Load Balancer
   │
   │ Security Group
   ▼
ECS Service
   │
   ▼
Fargate Tasks
```

As ECS Tasks podem permanecer em **Private Subnets**, recebendo tráfego somente através do Application Load Balancer.

IAM Roles e Policies são utilizadas para fornecer apenas as permissões necessárias para execução das Tasks e acesso aos serviços AWS utilizados pela aplicação.

---

## 🧹 Removendo a infraestrutura

Para remover todos os recursos gerenciados pelo Terraform:

```bash
terraform destroy
```

Revise cuidadosamente os recursos que serão removidos antes de confirmar a operação.
V2
---
