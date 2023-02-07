locals {
  app_role_assignments = flatten([
    for rra, required_resource_access in var.required_resource_access :
    [for ra in required_resource_access.resource_access : [
      {
        binding_name       = "${rra.resource_object_id}-${ra.id}"
        app_role_id        = ra.id
        resource_object_id = rra.resource_object_id
      }
    ] if lower(ra.type) == "role"]
  ])

  /* Needs to get a row for each rra.resource_object_id, and group oauth2_permission_scope_ids as a list. */
  delegate_assignments = flatten([
    for rra, required_resource_access in var.required_resource_access :
    [for ra in required_resource_access.resource_access : [
      {
        binding_name       = "${rra.resource_object_id}-${ra.id}"
        claims_id          = toset(rra.resource_access[*].id) //Needs to be the names of just the scope resources for the given resource_object_id
        resource_object_id = rra.resource_object_id
      }
    ] if lower(ra.type) == "scope"]
  ])


//Almost, but not quite.
  delegate_groups = flatten([
    for rra, required_resource_access in var.required_resource_access :
    [for ra in required_resource_access.resource_access : [
      {
        binding_name       = "${rra.resource_object_id}-${ra.id}"
        claims_id          = toset([for t in rra.resource_access : t.id if(lower(t.type) == "scope")]) #Needs to be the names of just the scope resources for the given resource_object_id
        resource_object_id = rra.resource_object_id
      }
      ] if lower(ra.type) == "scope"
    ] 
  ])
}
