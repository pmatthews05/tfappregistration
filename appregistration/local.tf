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


  delegate_groups = flatten([
    for rra, required_resource_access in var.required_resource_access :
    [
      {
        claims_id          = toset([for t in rra.resource_access : t.id if(lower(t.type) == "scope")]) #Needs to be the names of just the scope resources for the given resource_object_id
        resource_object_id = rra.resource_object_id
      }
    ] 
  ])

  delegate_non_empty = [for rra in local.delegate_groups : rra if(length(rra.claims_id) != 0)]
}
