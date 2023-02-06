resource "azuread_service_principal" "msgraph" {
  application_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
  use_existing   = true
}

resource "azuread_service_principal" "sharepoint" {
  application_id = data.azuread_application_published_app_ids.well_known.result.Office365SharePointOnline
  use_existing   = true
}

module "appreg_grant" {
  source = "./appregistration"
  name   = "appandgrants"

  required_resource_access = [
    {
      resource_app_id    = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
      resource_object_id = azuread_service_principal.msgraph.object_id
      resource_access = [
        {
          id   = azuread_service_principal.msgraph.app_role_ids["Application.Read.All"]
          type = "Role"
        },
        {
          id   = azuread_service_principal.msgraph.app_role_ids["Directory.ReadWrite.All"]
          type = "Role"
        },
        {
          id   = azuread_service_principal.msgraph.app_role_ids["Sites.FullControl.All"]
          type = "Role"
        },
        {
          id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["Group.ReadWrite.All"]
          type = "Scope"
        },
        {
          id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["User.Read"]
          type = "Scope"
        },
      ]
    },
    {
      resource_app_id    = data.azuread_application_published_app_ids.well_known.result.Office365SharePointOnline
      resource_object_id = azuread_service_principal.sharepoint.object_id
      resource_access = [
        {
          id   = azuread_service_principal.sharepoint.app_role_ids["Sites.FullControl.All"]
          type = "Role"
        }
      ]
    }
  ]
}
