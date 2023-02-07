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
      resource_service_principal = azuread_service_principal.msgraph
      resource_access = [
        {
          name   = "Application.Read.All"
          type = "Role"
        },
        {
          name   = "Directory.ReadWrite.All"
          type = "Role"
        },
        {
          name   = "Sites.FullControl.All"
          type = "Role"
        },
        {
          name   =  "Group.ReadWrite.All"
          type = "Scope"
        },
        {
          name   ="User.Read"
          type = "Scope"
        },
      ]
    },
    {
      resource_app_id    = data.azuread_application_published_app_ids.well_known.result.Office365SharePointOnline
      resource_service_principal = azuread_service_principal.sharepoint
      resource_access = [
        {
          name = "Sites.FullControl.All"
          type = "Role"
        }
      ]
    }
  ]
}
