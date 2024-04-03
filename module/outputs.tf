output "endpoint_address" {
  value = module.rds_intance.endpoint_address
}
output "id" {
  value = module.rds_intance.id
}
output "dns_record" {
  value = aws_route53_record.main.name
}