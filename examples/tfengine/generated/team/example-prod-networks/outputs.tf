
output "bastion_service_account" {
  value = module.bastion_vm.service_account

}
output "project_id" {
  value = module.project.project_id
}

output "project_number" {
  value = module.project.project_number
}
