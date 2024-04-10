########################################################################################################
#                                                                                                      #
#                                     CONNECT PROVIDER - AWS    :)                                     #
#                                                                                                      #
########################################################################################################

provider "aws" {
  #Região onde será configurado seu recurso. Deixei us-east-1 como default
  region = "us-east-1"

  #Conta mãe que será responsável pelo provisionamento do recurso.
  profile = ""

  #Assume Role necessária para o provisionamento de recurso, caso seja via role.
  assume_role {
    role_arn = "" #Role que será assumida pela sua conta principal :)
  }
}

#Configurações de backend, neste caso para armazenar o estado do recurso via Bucket S3.
terraform {
  backend "s3" {
    #Profile (conta) de onde está o bucket que você irá armazenar seu tfstate 
    profile = ""

    #Nome do Bucket
    bucket = ""

    #Caminho da chave para o recurso que será criado
    key = "caminho-da-chave/exemplo/terraform.tfstate"

    #Região onde será configurado seu recurso. Deixei us-east-1 como default
    region = "us-east-1"

    #Valores de segurança. Encriptação, Validação de credenciais e Check da API.
    encrypt                     = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
  }
}

########################################################################################################
#                                                                                                      #
#                                     DECLARAÇÃO DE VARIÁVEIS LOCAIS   :)                              #
#                                                                                                      #
########################################################################################################

locals {
  vpc_id                       = ""
  domain_name                  = ""
  resource_name                = ""
  region                       = ""
  account_id                   = ""
  instance_type                = ""
  rds_engine                   = ""
  engine_version               = ""
  parameter_group_family       = ""
  storage_type                 = ""
  storage                      = ""
  multi_az                     = ""
  publicly_accessible          = ""
  storage_encrypted            = ""
  auto_version_upgrade         = ""
  apply_immediately            = ""
  skip_final_snapshot          = ""
  ca_cert_identifier           = ""
  performance_insights_enabled = ""
  true_options                 = ""

  # BACKUP                
  backup_window           = ""
  backup_retention_period = ""
  maintenance_window      = ""
  monitoring_interval     = ""

  # TAGS
  default_tags = {
    Area     = ""
    Ambiente = ""
    SubArea  = ""
  }

  # USUÁRIO E SENHA (Necessário a criação e declaração do arquivo terraform.tfvars)
  master_username = ""
  master_password = ""
}
