######################################################################################################################
#                                                                                                                    #
#                                                 DB INSTANCE (RDS)                                                  #
#                                                                                                                    #
######################################################################################################################

resource "aws_db_instance" "main" {
  count = var.create ? 1 : 0

  # Configurações do RDS
  identifier                 = lower(replace(var.db_name, " ", "-"))
  instance_class             = var.instance_type
  engine                     = var.rds_engine
  engine_version             = var.engine_version
  storage_type               = var.storage_type
  allocated_storage          = var.storage
  multi_az                   = var.multi_az
  publicly_accessible        = var.publicly_accessible
  storage_encrypted          = var.storage_encrypted
  auto_minor_version_upgrade = var.auto_version_upgrade
  apply_immediately          = var.apply_immediately
  skip_final_snapshot        = var.skip_final_snapshot
  iops                       = var.iops_for_disk
  ca_cert_identifier         = var.ca_cert_identifier

  # Usuário e senha do RDS
  username = var.username
  password = var.password

  # Logs & perfomance
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  performance_insights_enabled    = var.performance_insights_enabled

  # Parte integrada de rede (VPC, SG, Subnet, etc...)
  vpc_security_group_ids = var.security_group_id
  db_subnet_group_name   = length(aws_db_subnet_group.main) > 0 ? aws_db_subnet_group.main.0.id : null

  # Parameter Group
  parameter_group_name = length(aws_db_parameter_group.main) > 0 ? aws_db_parameter_group.main.0.name : var.parameter_group_name

  # Backup & Janela de manutenção
  backup_window           = var.backup_window
  backup_retention_period = var.backup_retention_period
  maintenance_window      = var.maintenance_window
  monitoring_interval     = var.monitoring_interval

  # Recusos necessários apenas esporadicamente
  #replicate_source_db       = var.db_replicate_source
  snapshot_identifier       = var.snapshot_identifier
  final_snapshot_identifier = "${lower(replace(var.db_name, " ", "-"))}-${random_id.snapshot_identifier.0.hex}-final-snapshot"
  # copy_tags_to_snapshot = var.copy_tags_to_snapshot

  # Monitoring Role
  monitoring_role_arn = length(aws_iam_role.main) > 0 ? aws_iam_role.main.0.arn : null

  # Tags
  tags = merge(
    {
      "Name" = var.db_name
    },
    var.default_tags
  )

  lifecycle {
    ignore_changes = [snapshot_identifier]
  }

  timeouts {
    update = var.update_timeouts
    create = var.create_timeouts
  }

  depends_on = [var.enabled_depends_on]
}

######################################################################################################################
#                                                                                                                    #
#                                                 DB PARAMETER GROUP (RDS)                                           #
#                                                                                                                    #
######################################################################################################################

resource "aws_db_parameter_group" "main" {
  count = var.create ? length(var.db_parameter_group) : 0

  name   = lookup(var.db_parameter_group[count.index], "name", null)
  family = lookup(var.db_parameter_group[count.index], "family", null)

  dynamic "parameter" {
    for_each = lookup(var.db_parameter_group[count.index], "parameter", null)
    content {
      name  = lookup(parameter.value, "name", null)
      value = lookup(parameter.value, "value", null)
    }
  }
}

######################################################################################################################
#                                                                                                                    #
#                                                 DB SUBNET GROUP (RDS)                                              #
#                                                                                                                    #
######################################################################################################################

resource "aws_db_subnet_group" "main" {
  count = var.create ? length(var.db_subnet_group) : 0

  name       = lookup(var.db_subnet_group[count.index], "name", null)
  subnet_ids = lookup(var.db_subnet_group[count.index], "subnet_ids", null)

  tags = merge(
    {
      "Name" = "${format("%s", var.db_name)}-Subnet-Group"
    },
    var.default_tags,
  )
}

#Se precisar de recursos de rede separado, específicos para o RDS, utilizar os recursos abaixo:

/*
resource "aws_eip" "database" {
    count   = var.create ? length(var.subnet_database) : 0 

    vpc = true
    tags    = merge(
        {
            "Name" = "${var.vpc_name}-Database-ElasticIP"
        },
        var.default_tags
    )
}

resource "aws_nat_gateway" "database" {
    count   = var.create ? length(var.subnet_database) : 0   

    allocation_id = element(aws_eip.database.*.id, count.index)
    subnet_id     = element(aws_subnet.database.*.id, count.index)
    tags = merge(
        {
            Name = "${var.vpc_name}-Database-NATGateway"
        },
        var.default_tags
    )
}

resource "aws_route_table" "database" {
    count   = var.create ? length(var.subnet_database) : 0

    vpc_id     = data.aws_vpc.selected.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = element(aws_nat_gateway.database.*.id, count.index)
    }
    tags = merge(
        {
            "Name" = format("%s", "${var.vpc_name}-RouteTable-Database-Private")
        },
        var.default_tags
    )
}

resource "aws_route_table_association" "database" {
    count   = var.create ? length(var.subnet_database) : 0

    route_table_id = element(aws_route_table.database.*.id, count.index)
    subnet_id = element(aws_subnet.database.*.id, count.index)
}
*/