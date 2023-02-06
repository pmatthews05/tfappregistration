output "application_id" {
  value = azuread_application.app.application_id
}

output "application_display_name" {
  value = azuread_application.app.display_name
}

output "object_id" {
  value = azuread_application.app.object_id
}

output "service_principal_id" {
  value = azuread_service_principal.service_principal.id
}

output "app_role_ids" {
  value = azuread_application.app.app_role_ids
}

output "service_principal_object_id" {
  value = azuread_service_principal.service_principal.object_id
}

output "delegate_assignments_flat" {
  value = local.delegate_assignments
}