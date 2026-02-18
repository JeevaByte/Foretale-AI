output "dev_account_id" {
  value = aws_organizations_account.client_dev.id
}
output "uat_account_id" {
  value = aws_organizations_account.client_uat.id
}
output "prod_account_id" {
  value = aws_organizations_account.client_prod.id
}
output "clients_ou_id" {
  value = aws_organizations_organizational_unit.clients.id
}
output "dev_ou_id" {
  value = aws_organizations_organizational_unit.dev.id
}
output "uat_ou_id" {
  value = aws_organizations_organizational_unit.uat.id
}
output "prod_ou_id" {
  value = aws_organizations_organizational_unit.prod.id
}
