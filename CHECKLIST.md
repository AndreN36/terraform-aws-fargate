# ✅ CHECKLIST - FARGATE COM TERRAFORM

## 📋 Antes de Iniciar

### Pré-requisitos
- [ ] AWS CLI instalado e configurado
- [ ] Terraform >= 1.0.0 instalado
- [ ] Credenciais AWS configuradas (`aws configure`)
- [ ] Permissões IAM para criar recursos ECS, VPC, IAM, etc.
- [ ] S3 Bucket para estado Terraform existe e é acessível

### Código Docker
- [ ] Imagem Docker já está no ECR ou Docker Hub público
- [ ] Porta da imagem corresponde com `container_port`
- [ ] Imagem foi testada localmente

## 🔧 Configuração Inicial

### 1. Preparação do Workspace
```bash
cd fargate/

# Copiar arquivo de exemplo
cp terraform.tfvars.example terraform.tfvars

# Editar valores para seu ambiente
vim terraform.tfvars
```

### Valores Obrigatórios em terraform.tfvars
- [ ] `app_name` definido
- [ ] `environment` definido (dev/staging/prod)
- [ ] `aws_region` definido
- [ ] `container_image` definida (URL completa ECR ou Docker Hub)
- [ ] `container_port` definida

### Valores Opcionais (com bom padrão)
- [ ] `container_cpu` validado (256, 512, 1024, 2048, 4096)
- [ ] `container_memory` validada (compatível com CPU escolida)
- [ ] `desired_count` >= 1
- [ ] `vpc_cidr` não conflita com infraestrutura existente
- [ ] `enable_load_balancer` conforme necessidade
- [ ] `log_retention_days` apropriado para ambiente

## 🧪 Validação do Terraform

### 1. Inicializar Backend
```bash
terraform init
```
- [ ] Comando executado com sucesso
- [ ] Backend S3 confirmado
- [ ] Nenhum erro de credenciais

### 2. Validar Sintaxe
```bash
terraform validate
```
- [ ] Comando retorna "Valid"
- [ ] Nenhum erro de sintaxe

### 3. Formatar Código
```bash
terraform fmt -recursive
```
- [ ] Todos os arquivos formatados corretamente

### 4. Planejar Recursos
```bash
terraform plan -out=tfplan

# Para ambiente específico:
terraform plan -var-file="terraform.dev.tfvars" -out=tfplan
```
- [ ] Plano mostra 0 erros
- [ ] Número de recursos esperado (~45-50 recursos)
- [ ] Recursos a criar conforme esperado:
  - [ ] 1 VPC
  - [ ] 2 Subnets Públicas
  - [ ] 2 Subnets Privadas
  - [ ] 1 IGW
  - [ ] 2 NAT Gateways
  - [ ] 2 EIPs
  - [ ] 2 Route Tables Privadas
  - [ ] 1 Route Table Pública
  - [ ] 2 Security Groups
  - [ ] 1 CloudWatch Log Group
  - [ ] 1 ECS Cluster
  - [ ] 1 ECS Task Definition
  - [ ] 1 ECS Service
  - [ ] 1 ALB (se habilitado)
  - [ ] 1 Target Group (se habilitado)
  - [ ] 1 ALB Listener (se habilitado)
  - [ ] 2 IAM Roles
  - [ ] 1 CloudWatch Log Group

## 🚀 Aplicação de Recursos

### 5. Revisar Plano Detalhado
```bash
terraform show tfplan
```
- [ ] Revisar cada recurso a ser criado
- [ ] Confirmar nomes, tags, configurações
- [ ] Nenhuma exclusão inesperada

### 6. Aplicar Configuração
```bash
terraform apply tfplan
```
- [ ] Comando executado com sucesso
- [ ] Não há erros durante criação
- [ ] Output mostra valores dos recursos criados

## ✅ Validação Pós-Deployment

### 7. Verificar Recursos na AWS

#### VPC e Networking
```bash
aws ec2 describe-vpcs --filter "Name=tag:Name,Values=MY_APP_NAME-vpc-ENVIRONMENT"
aws ec2 describe-subnets --filters "Name=vpc-id,Values=VPC_ID"
```
- [ ] VPC criada corretamente
- [ ] Subnets em diferentes AZs
- [ ] NAT Gateways operacionais

#### Security Groups
```bash
aws ec2 describe-security-groups --filter "Name=group-name,Values=MY_APP_NAME-*"
```
- [ ] 2 Security Groups criados
- [ ] ALB SG com portas 80/443
- [ ] ECS SG com port container_port

#### ECS Cluster
```bash
aws ecs list-clusters
aws ecs describe-clusters --clusters MY_APP_NAME-cluster-ENVIRONMENT
```
- [ ] Cluster criado
- [ ] Container Insights habilitado

#### ECS Service
```bash
aws ecs describe-services --cluster MY_APP_NAME-cluster-ENVIRONMENT \
  --services MY_APP_NAME-service-ENVIRONMENT
```
- [ ] Service criado
- [ ] Desired count == desired_count
- [ ] Tasks iniciando/rodando
- [ ] Running count aumentando

#### ECS Tasks
```bash
aws ecs list-tasks --cluster MY_APP_NAME-cluster-ENVIRONMENT
aws ecs describe-tasks --cluster MY_APP_NAME-cluster-ENVIRONMENT \
  --tasks <TASK_ARN>
```
- [ ] Tasks criadas e rodando
- [ ] Task definition correta
- [ ] Subnets privadas confirmadas
- [ ] Security groups aplicados

#### Load Balancer
```bash
aws elbv2 describe-load-balancers --query 'LoadBalancers[*].[LoadBalancerName,DNSName]'
aws elbv2 describe-target-groups --load-balancer-arn <ALB_ARN>
```
- [ ] ALB criado (se habilitado)
- [ ] Target Group com targets saudáveis
- [ ] Listener na porta 80

#### IAM Roles
```bash
aws iam list-roles --query 'Roles[*].[RoleName]' | grep MY_APP_NAME
```
- [ ] 2 Roles criadas (execution e task)
- [ ] Policies anexadas corretamente

#### CloudWatch Logs
```bash
aws logs describe-log-groups --query 'logGroups[*].[logGroupName]'
aws logs tail /ecs/MY_APP_NAME-ENVIRONMENT --follow
```
- [ ] Log Group criado
- [ ] Log streams aparecendo
- [ ] Logs sendo recebidos

### 8. Teste de Conectividade

#### ALB Endpoint
```bash
ALB_DNS=$(terraform output -raw alb_dns_name)
curl -v http://$ALB_DNS
```
- [ ] ALB responde (pode ser 502 se app ainda iniciando)
- [ ] DNS resolvel
- [ ] Conexão TCP estabelecida

#### Target Health
```bash
aws elbv2 describe-target-health --target-group-arn <TG_ARN>
```
- [ ] Targets marcados como healthy
- [ ] Reason: None (se healthy)

#### Container Logs
```bash
aws logs tail /ecs/MY_APP_NAME-ENVIRONMENT --follow --since 5m
```
- [ ] Aplicação iniciando corretamente
- [ ] Nenhum erro de inicialização
- [ ] Logs indicando app rodando na porta correta

## 🔍 Troubleshooting

### Tasks não iniciam
- [ ] Verificar imagem ECR está acessível
- [ ] Validar tag de imagem existe
- [ ] Verificar IAM permissions (Task Execution Role)
- [ ] Revisar CloudWatch logs
```bash
aws logs tail /ecs/MY_APP_NAME-ENVIRONMENT --follow
```

### Target não fica healthy
- [ ] Verificar porta container_port está correta
- [ ] Confirmar app responde em / (health check path)
- [ ] Revisar security group rules
- [ ] Aumentar timeout health check se app lento

### Erro de credenciais
- [ ] Confirmar AWS credentials configuradas
- [ ] Validar permissões IAM do usuário/role
- [ ] Verificar backend S3 acessível

### VPC CIDR conflita com existente
- [ ] Editar `vpc_cidr` em terraform.tfvars
- [ ] Usar CIDR não utilizado (ex: 10.1.0.0/16)
- [ ] Re-aplicar: `terraform apply -var-file="terraform.tfvars"`

## 📊 Performance

### Monitorar Recursos
```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/ECS \
  --metric-name CPUUtilization \
  --dimensions Name=ServiceName,Value=MY_APP_NAME-service-ENVIRONMENT \
              Name=ClusterName,Value=MY_APP_NAME-cluster-ENVIRONMENT \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 300 \
  --statistics Average
```
- [ ] CPU usage sob limite (70%)
- [ ] Memory usage sob limite (80%)
- [ ] Nenhuma falha de task

## 🔐 Segurança

- [ ] terraform.tfvars **NÃO** está versionado (adicione a .gitignore)
- [ ] Credenciais AWS não estão hardcoded
- [ ] IAM roles com least privilege
- [ ] Security groups restrictivos
- [ ] Container rodando como non-root (se aplicável)
- [ ] Secrets Manager para credenciais sensíveis

## 📝 Documentação

- [ ] Terraform outputs documentados
- [ ] terraform.tfvars comentado para seu ambiente
- [ ] Playbook de deploy criado para CI/CD
- [ ] Runbook de troubleshooting disponível

## 🎯 Verificação Final

- [ ] Todas as verificações acima completadas
- [ ] Aplicação respondendo corretamente via ALB
- [ ] Logs aparecendo no CloudWatch
- [ ] Health checks passando
- [ ] Auto scaling funcionando (se config permite)
- [ ] Terraform plan mostra sem alterações (estado estável)

## 🔄 Próximas Ações

- [ ] Configurar monitoramento/alertas CloudWatch
- [ ] Adicionar HTTPS com ACM
- [ ] Implementar CI/CD pipeline
- [ ] Configurar backup/disaster recovery
- [ ] Testar failover de AZ
- [ ] Documentar runbooks operacionais

## 📞 Suporte

Em caso de problemas:
1. Revisar ARCHITECTURE.md para entender componentes
2. Revisar BEST_PRACTICES.md para configurações comuns
3. Verificar logs CloudWatch
4. Revisar plano Terraform detalhado
5. Consultar documentação AWS oficial

---

**Data de Criação**: 2024-08-12
**Versão Terraform**: >= 1.0.0
**AWS Provider**: ~> 3.0
