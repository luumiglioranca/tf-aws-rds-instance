variable "create" {
  type    = bool
  default = true
}

variable "db_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "rds_engine" {
  type    = string
  default = null
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "engine_version" {
  type    = string
  default = null
}

variable "storage" {
  type    = number
  default = null
}

variable "iops_for_disk" {
  type    = number
  default = null
}

variable "maintenance_window" {
  type    = string
  default = null
}

variable "storage_type" {
  type    = string
  default = null
}

variable "auto_version_upgrade" {
  type    = bool
  default = false
}

variable "apply_immediately" {
  type    = bool
  default = false
}

variable "backup_window" {
  type    = string
  default = null
}

variable "backup_retention_period" {
  type    = number
  default = null
}

variable "security_group_id" {
  type    = list(any)
  default = []
}

variable "snapshot_identifier" {
  type    = string
  default = null
}

variable "skip_final_snapshot" {
  type    = bool
  default = true
}

variable "publicly_accessible" {
  type    = bool
  default = false
}

variable "storage_encrypted" {
  type    = bool
  default = false
}

variable "enabled_cloudwatch_logs_exports" {
  type    = any
  default = []
}

variable "password" {
  type    = string
  default = null
}

variable "username" {
  type    = string
  default = null
}

variable "performance_insights_enabled" {
  type    = bool
  default = false
}

variable "monitoring_interval" {
  type    = number
  default = 0
}

variable "ca_cert_identifier" {
  type    = string
  default = null
}

variable "copy_tags_to_snapshot" {
  type    = bool
  default = true
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "db_subnet_group" {
  type    = any
  default = []
}

variable "db_parameter_group" {
  type    = any
  default = []
}

variable "parameter_group_name" {
  type    = any
  default = ""
}

variable "db_replicate_source" {
  type    = string
  default = null
}

variable "enabled_depends_on" {
  type    = list(any)
  default = []
}

variable "update_timeouts" {
  type    = string
  default = null
}

variable "create_timeouts" {
  type    = string
  default = null
}

variable "enhanced_monitoring" {
  type    = bool
  default = false
}