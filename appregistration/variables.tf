variable "name" {
    description = "name of app registration"
    type = string
}

variable "web" {
  description = "Configures web related settings for this application"
  type        = any
  default     = null
}

variable "required_resource_access" {
  description = "A collection of required resource access for this application"
  type        = set(object({
    resource_app_id = string,
    resource_object_id = string
    resource_access = set(object({
      id = string
      type = string
    }))
  }))
  default     = []
}

variable "api" {
  description = "An optional api block, which configures API related settings for this application."
  type        = any
  default     = null
}

variable "identifier_uris" {
  description = "A list of user-defined URI(s) that uniquely identify a Web application within it's Azure AD tenant, or within a verified custom domain if the application is multi-tenant."
  type        = list(string)
  default     = []
}

variable "app_role" {
  description = "A collection of app_role blocks."
  type        = any
  default     = []
}