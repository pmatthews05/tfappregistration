locals {

  app_role_assignments = [
    for rra, required_resource_access in var.required_resource_access :
    {
      resource_app_id    = rra.resource_app_id
      resource_object_id = rra.resource_service_principal.object_id
      resource_app_name  = rra.resource_service_principal.display_name
      resource_access = concat([for ra in required_resource_access.resource_access :
        {
          id    = rra.resource_service_principal.app_role_ids[ra.name]
          name  = ra.name
          type  = ra.type
          admin = true
        }
        if lower(ra.type) == "role"],
        [for ra in required_resource_access.resource_access :
          {
            id    = rra.resource_service_principal.oauth2_permission_scope_ids[ra.name]
            type  = ra.type
            name  = ra.name
            admin = rra.resource_service_principal.oauth2_permission_scopes[index(rra.resource_service_principal.oauth2_permission_scopes.*.id, rra.resource_service_principal.oauth2_permission_scope_ids[ra.name])].type == "Admin" ? true : false
          }
        if lower(ra.type) == "scope"]
      )
    }
  ]

  app_role_assignments_grants = flatten([
    for ara in local.app_role_assignments :
    [for ra in ara.resource_access : [
      {
        binding_name       = "${ara.resource_app_name}-${ra.name}"
        resource_app_id    = ara.resource_app_id
        resource_object_id = ara.resource_object_id
        resource_app_name  = ara.resource_app_name
        id                 = ra.id
        type               = ra.type
      }
    ] if lower(ra.type) == "role"]
  ])

  delegate_grants = flatten([
    for ara in local.app_role_assignments :
    [
      {
        claims_id          = toset([for t in ara.resource_access : t.name if(lower(t.type) == "scope" && coalesce(t.admin, false) == true)])
        resource_object_id = ara.resource_object_id
      }
    ]
  ])

  delegate_grants_non_empty = [for rra in local.delegate_grants : rra if(length(rra.claims_id) != 0)]
}
