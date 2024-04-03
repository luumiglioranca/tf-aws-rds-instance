output "endpoint_address" {
  value = module.rds_intance.endpoint_address
}

output "id" {
  value = module.rds_intance.id
}

output "db_name" {
  value = module.rds_intance.db_name
}

output "dns_record" {
  value = aws_route53_record.main.name
}

output "password" {
  value     = random_password.password.result
  sensitive = true
}