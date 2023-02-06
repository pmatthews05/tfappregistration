resource "azuread_application" "app" {
  display_name    = "appreg-${var.name}"
  identifier_uris = var.identifier_uris

  dynamic "web" {
    for_each = var.web != null ? ["true"] : []
    content {
      redirect_uris = lookup(var.web, "redirect_uris", null)

      dynamic "implicit_grant" {
        for_each = lookup(var.web, "implicit_grant", null) != null ? [1] : []
        content {
          access_token_issuance_enabled = lookup(var.web.implicit_grant, "access_token_issuance_enabled", null)
          id_token_issuance_enabled     = lookup(var.web.implicit_grant, "id_token_issuance_enabled", null)
        }
      }
    }
  }

  dynamic "required_resource_access" {
    for_each = var.required_resource_access != null ? var.required_resource_access : []

    content {
      resource_app_id = required_resource_access.value.resource_app_id

      dynamic "resource_access" {
        for_each = required_resource_access.value.resource_access
        iterator = access
        content {
          id   = access.value.id
          type = access.value.type
        }
      }
    }
  }

  dynamic "api" {
    for_each = var.api != null ? ["true"] : []
    content {
      mapped_claims_enabled = lookup(var.api, "mapped_claims_enabled", null)

      dynamic "oauth2_permission_scope" {
        for_each = lookup(var.api, "oauth2_permission_scope", [])
        content {
          admin_consent_description  = oauth2_permission_scope.value["admin_consent_description"]
          admin_consent_display_name = oauth2_permission_scope.value["admin_consent_display_name"]
          enabled                    = lookup(oauth2_permission_scope.value, "enabled", true)
          id                         = oauth2_permission_scope.value["id"]
          type                       = oauth2_permission_scope.value["type"]
          user_consent_description   = lookup(oauth2_permission_scope.value, "user_consent_description", null)
          user_consent_display_name  = lookup(oauth2_permission_scope.value, "user_consent_display_name", null)
          value                      = lookup(oauth2_permission_scope.value, "value", null)
        }
      }
    }
  }

  dynamic "app_role" {
    for_each = var.app_role != null ? var.app_role : []
    content {
      allowed_member_types = app_role.value.allowed_member_types
      description          = app_role.value.description
      display_name         = app_role.value.display_name
      enabled              = lookup(app_role.value, "enabled", true)
      id                   = app_role.value.id
      value                = lookup(app_role.value, "value", null)
    }
  }
}

resource "azuread_service_principal" "service_principal" {
  application_id               = azuread_application.app.application_id
}

#Loop through required_resource_access, flattening
resource "azuread_app_role_assignment" "grant_admin" {
  #for_each = { for ara in local.app_role_assignments }
  #app_role_id = each.value.app_role_id
  #principal_object_id = azuread_service_principal.service_principal.object_id
  #resource_object_id = each.value.resource_object_id
  count               = length(local.app_role_assignments)
  app_role_id         = local.app_role_assignments[count.index].app_role_id
  principal_object_id = azuread_service_principal.service_principal.object_id
  resource_object_id  = local.app_role_assignments[count.index].resource_object_id
}

//Hard Coded example of granted Delegate permission for Graph.
resource "azuread_service_principal_delegated_permission_grant" "grant_admin" {
  service_principal_object_id          = azuread_service_principal.service_principal.object_id
  resource_service_principal_object_id = "824be4d8-2fe5-4c93-b688-cdb62b9c1353"
  claim_values                         = ["Group.ReadWrite.All", "User.Read"]
}