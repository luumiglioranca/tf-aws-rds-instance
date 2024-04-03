# AWS Terraform - DB Instance
Este módulo provisionar os seguintes recursos:

1: [IAM Role - Monitoring RDS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)

2: [IAM Role Policy Attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)

3: [DB Instance - RDS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance)

4: [DB Parameter Group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group)

5: [DB Subnet Group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group)

6: [DNS Recourd - Route53](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)

**_Importante:_** A documentação da haschicorp é bem completa, se quiserem dar uma olhada, segue o link do glossário com todos os recursos do terraform: https://registry.terraform.io/providers/hashicorp/aws/latest/docs

**_Importante (2):_** Esse repositório terá duas possibilidades, uma na criação de um RDS single-az com duas zonas de disponibilidade e outra multi-az com réplica de banco de dados em três zonas de disponibilidade, basta escolher qual você deverá seguir.

## Exemplo de um module pré-configurado [SINGLE-AZ]:)

### Primeiro um exemplo prático de criação de um security group para o RDS
`Caso de uso`:  Module para criação do SG (Inbound)
```bash

module "security_group_for_rds" {

  source = "git@github.com:luumiglioranca/tf-aws-security-group.git//resource"

  description = "Security Group para o ${local.resource_name} :)"

  security_group_name = "${local.resource_name}-sg"
  vpc_id              = data.aws_subnet_ids.subnet_priv.id

  ingress_rule = [
    {
      description = "RDS MySQL Ingress Rede Local"
      type        = "ingress"
      from_port   = "3306"
      to_port     = "3306"
      protocol    = "tcp"
      cidr_blocks = [data.aws_vpc.selected.cidr_block]
    },
    {
      description = "Peering/Proxy Acess"
      type        = "ingress"
      from_port   = "3306"
      to_port     = "3306"
      protocol    = "tcp"
      cidr_blocks = ["x.x.x.x/x"]
    }
  ]

  default_tags = merge(
    {
      Name = "sg-${local.resource_name}"

  }, local.default_tags)
}

```

### Depois do SG criado, módulo de criação do recurso (RDS) 
`Caso de uso`: Module para criação do RDS
```bash

module "rds_intance" {
  source = "git@github.com:luumiglioranca/tf-aws-db-rds-instance.git//develop+homolog/resources"

  # Configurações do RDS
  db_name              = local.resource_name
  instance_type        = "db.t3.medium"
  rds_engine           = "mysql"
  engine_version       = "8.0"
  storage_type         = "gp2"
  storage              = "50"
  multi_az             = "false"
  publicly_accessible  = "false"
  storage_encrypted    = "false"
  auto_version_upgrade = "true"
  apply_immediately    = "true"
  skip_final_snapshot  = "true"
  iops_for_disk        = "3000"
  ca_cert_identifier   = "rds-ca-2019"

  # Credenciais para o Root Database
  username = local.master_username
  password = local.master_password

  # Logs & perfomance
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]
  performance_insights_enabled    = "false"

  # Parte integrada de rede (VPC, SG, Subnet, etc...)
  security_group_id = [module.security_group_for_rds.security_group_id]

  #snapshot_identifier = data.aws_db_snapshot.latest_snapshot.id

  # Parameter Group
  db_parameter_group = [{
    name   = "${local.resource_name}-parameter"
    family = "mysql5.7"

    parameter = [
      {
        name  = "character_set_server"
        value = "utf8"
      },
      {
        name  = "character_set_client"
        value = "utf8"
      }
    ]
  }]

  # Subnet Group
  db_subnet_group = [{
    name = "${local.resource_name}-subnet-group"
    subnet_ids = [
      tolist(data.aws_subnet_ids.subnet_priv.ids)[0],
      tolist(data.aws_subnet_ids.subnet_priv.ids)[1]
    ]
  }]

  #Backup & Janela de manutenção
  backup_window           = "20:00-21:00"
  backup_retention_period = "14"
  maintenance_window      = "Mon:00:00-Mon:03:00"
  monitoring_interval     = "0"

  #Tags
  default_tags = local.default_tags
}

```
## Para executar esse módulo você precisará dos seguintes arquivos: 

| Name | Version|
|------|--------|
| datasource.tf | Colhendo as informações de SSL, Subnet, VPC, Snapshot e etc... |
| main.tf  | Contendo o módulo com as variáveis declaradas (SG & RDS)| 
| outputs | Busca valores imputados no código fonte |
| provider.tf  | Contém tfstate (S3 Payer) & Conta que será provisionado o recurso | 
| route_53.tf  | Criação de DNS Record na conta Atena | 
| terraform.tfvars.tf  | Necessário declarar o usuário e senha root do database | 
| variables.tf  | Contendo as variáveis necessárias declaradas no código fonte | 


## Arquivo Variables.tf

Variáveis e seus atributos:

PS: Também disponível na documentação

- `master_username`: (Obrigatorio) Usuário ROOT do batase.
- `master_password`: (Obrigatorio) Senha do usuário ROOT.


## Arquivo de Outputs

| Name | Description |
| ---- | ----------- |
| endpoint | Retorna o endpoint do RDS |
| id | Retorna o ID do RDS |
| name | Retorna o nome do RDS|

## Espero que seja útil a todos!!!!! Grande abraço <3


**_Importante:_** Qualquer dificuldade encontrada, melhoria ou se precisarem alterar alguma linha de código, só entrar em contato que te ajudo <3