locals {


  app_role_assignments = [
    for rra, required_resource_access in var.required_resource_access :
    {
      resource_app_id    = rra.resource_app_id
      resource_object_id = rra.resource_service_principal.object_id
      resource_access = concat([for ra in required_resource_access.resource_access : 
        {
          id   = rra.resource_service_principal.app_role_ids[ra.name]
          type = ra.type
        }
        if lower(ra.type) == "role"],
        [for ra in required_resource_access.resource_access : 
          {
            id   = rra.resource_service_principal.oauth2_permission_scope_ids[ra.name]
            type = ra.type
          }
        if lower(ra.type) == "scope"]
      )
    }
  ]

  delegate_assignments = flatten([
    for rra, required_resource_access in var.required_resource_access :
    [for ra in required_resource_access.resource_access : [
      {
        binding_name       = "${rra.resource_service_principal.display_name}-${ra.name}"
        resource_app_id    = rra.resource_app_id
        id                 = rra.resource_service_principal.oauth2_permission_scope_ids[ra.name]
        resource_object_id = rra.resource_service_principal.object_id
        type               = ra.type
      }
    ] if lower(ra.type) == "scope"]
  ])

  app_role_assignments_grants = flatten([
    for rra, required_resource_access in var.required_resource_access :
    [for ra in required_resource_access.resource_access : [
      {
        binding_name       = "${rra.resource_service_principal.display_name}-${ra.name}"
        resource_app_id    = rra.resource_app_id
        id                 = rra.resource_service_principal.app_role_ids[ra.name]
        resource_object_id = rra.resource_service_principal.object_id
        type               = ra.type
      }
    ] if lower(ra.type) == "role"]
  ])
  delegate_grants = flatten([
    for rra, required_resource_access in var.required_resource_access :
    [
      {
        claims_id          = toset([for t in rra.resource_access : t.name if(lower(t.type) == "scope")]) #Needs to be the names of just the scope resources for the given resource_object_id
        resource_object_id = rra.resource_service_principal.object_id
      }
    ]
  ])

  delegate_grants_non_empty = [for rra in local.delegate_grants : rra if(length(rra.claims_id) != 0)]
}
