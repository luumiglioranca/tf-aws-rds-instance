#########################################################################################################
#                                                                                                       #
#                      MÓDULO PARA A CRIAÇÃO DA NOSSA INSTÂNCIA DE BANCO DE DADOS (RDS)                 #
#                                                                                                       #
#########################################################################################################

module "rds_intance" {
  source = "git@github.com:luumiglioranca/tf-aws-db-rds-instance.git//production/resource"

  # Configurações do RDS
  db_name              = local.resource_name
  instance_type        = local.instance_type
  rds_engine           = local.rds_engine
  engine_version       = local.engine_version
  storage_type         = local.storage_type
  storage              = local.storage
  multi_az             = local.multi_az
  publicly_accessible  = local.publicly_accessible
  storage_encrypted    = local.true_options
  auto_version_upgrade = local.true_options
  apply_immediately    = local.true_options
  skip_final_snapshot  = local.true_options
  ca_cert_identifier   = local.ca_cert_identifier
  #iops_for_disk       = local.iops_for_disk

  # Credenciais para o Root Database
  username = "admin"
  password = random_password.password.result

  # Logs & perfomance
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]
  performance_insights_enabled    = local.performance_insights_enabled

  # Parte integrada de rede (VPC, SG, Subnet, etc...)
  security_group_id = [module.security_group_for_rds.security_group_id]

  #snapshot_identifier = data.aws_db_snapshot.latest_snapshot.id

  # Parameter Group
  db_parameter_group = [{
    name   = "${local.resource_name}-parameter"
    family = "${local.parameter_group_family}"

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
      data.aws_subnet.priv_1a.id,
      data.aws_subnet.priv_1b.id,
      data.aws_subnet.priv_1c.id
    ]
  }]

  #Backup & Janela de manutenção
  backup_window           = local.backup_window
  backup_retention_period = local.backup_retention_period
  maintenance_window      = local.maintenance_window
  monitoring_interval     = local.monitoring_interval

  #Tags
  default_tags = local.default_tags
}

############################################################################################
#                                                                                          #
#                        GERAÇÃO DE UMA SENHA RANDÔMICA PARA O RDS :)                      #
#                                                                                          # 
############################################################################################ 

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}:?"
}

############################################################################################
#                                                                                          #
#                        MÓDULO PARA A CRIAÇÃO DO SECURITY GROUP PARA O RDS                #
#                                                                                          # 
############################################################################################ 

module "security_group_for_rds" {

  source = "git@github.com:luumiglioranca/tf-aws-security-group.git//resources"

  description = "Security Group para o ${local.resource_name} :)"

  security_group_name = "${local.resource_name}-sg"
  vpc_id              = data.aws_vpc.main.id

  ingress_rule = [
    {
      description = "RDS MySQL Ingress Rede Local"
      type        = "ingress"
      from_port   = "3306"
      to_port     = "3306"
      protocol    = "tcp"
      cidr_blocks = [data.aws_vpc.main.cidr_block]
    },
    #Regra necessária para comunicação com o proxy de rede da sua empresa
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

#########################################################################################################
#                                                                                                       #
#                 MÓDULO PARA A CRIAÇÃO DA NOSSA REPLICA PRODUTIVA DE BANCO DE DADOS (RDS)              #
#                                                                                                       #
#########################################################################################################

module "rds_intance_replica" {
  source = "git@github.com:luumiglioranca/tf-aws-db-rds-instance.git//production/resource"
  
 # Configurações da réplica
  db_name                         = "${local.resource_name}-replica"
  instance_type                   = local.instance_type
  db_replicate_source             = module.rds_intance.db_name
  security_group_id               = [module.security_group_for_rds.security_group_id]
  skip_final_snapshot             = local.true_options
  storage_encrypted               = local.true_options
  publicly_accessible             = local.publicly_accessible
  auto_version_upgrade            = local.true_options
  apply_immediately               = local.true_options
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]
  parameter_group_name            = "${local.resource_name}-parameter"
  default_tags                    = local.default_tags
  create_timeouts                 = "60m"
  multi_az                        = "false"
  performance_insights_enabled    = "false"
  enabled_depends_on              = [module.rds_intance]
}

resource "aws_route53_record" "route_53_replica" {
  provider   = aws.atena
  zone_id    = data.aws_route53_zone.edtech.zone_id
  
  name       = "${local.resource_name}-replica.${local.domain_name}"
  type       = "CNAME"
  ttl        = "10"
  records    = [module.rds_intance_replica.endpoint_address]
  depends_on = [module.rds_intance_replica]
}
