variable "kubecontext" {
  description = "The kubecontext"
}

variable "keycloak_admin_password" {
  description = "Keycloak admin user's password"
}

variable "keycloak_host" {
  # NOTE: terraform can't use /etc/hosts , for some reason.
  description = "The host to access keycloak"
}
