
# MinIO Realm
resource "keycloak_realm" "minio_realm" {
  realm        = "minio"
  enabled      = true
  ssl_required = "none"
}

resource "random_string" "keycloak_minio_client_id" {
  length  = 16
  special = false
}

resource "random_string" "keycloak_minio_client_secret" {
  length  = 32
  special = false
}

# https://github.com/minio/minio/blob/master/docs/sts/keycloak.md
locals {
  minio_client_id = "minio-${random_string.keycloak_minio_client_id.result}"
}
resource "keycloak_openid_client" "openid_client" {
  realm_id      = keycloak_realm.minio_realm.id
  client_id     = local.minio_client_id
  client_secret = random_string.keycloak_minio_client_secret.result

  name    = "minio client"
  enabled = true

  standard_flow_enabled = true

  access_type = "CONFIDENTIAL"
  valid_redirect_uris = [
    "*"
  ]

  # Seconds
  access_token_lifespan = "3600"

  service_accounts_enabled = true
}


resource "random_string" "keycloak_minio_user_password" {
  length  = 32
  special = false
}

resource "keycloak_user" "minio_user" {
  realm_id = keycloak_realm.minio_realm.id
  username = "admin"
  enabled  = true

  email      = "admin@statcan.gc.ca"
  first_name = "Admin"
  last_name  = "Strator"

  attributes = {
    policy = "readwrite"
  }

  initial_password {
    value     = random_string.keycloak_minio_user_password.result
    temporary = false
  }
}

resource "keycloak_openid_user_attribute_protocol_mapper" "minio_user_attribute_mapper" {
  realm_id  = keycloak_realm.minio_realm.id
  client_id = keycloak_openid_client.openid_client.id
  name      = "minio-attribute"

  user_attribute = "policy"
  claim_name     = "policy"
}

resource "keycloak_openid_audience_protocol_mapper" "minio_console_audience" {
  realm_id  = keycloak_realm.minio_realm.id
  client_id = keycloak_openid_client.openid_client.id
  name      = "minio-audience-mapper"

  included_custom_audience = "security-admin-console"
}


resource "keycloak_role" "minio_client_role" {
  realm_id    = keycloak_realm.minio_realm.id
  client_id   = keycloak_openid_client.openid_client.id
  name        = "admin"
  description = "$${role_admin}"
}

resource "kubernetes_secret" "minio_oidc_config" {
  metadata {
    name      = "minio-oidc-config"
    namespace = "minio-gateway"
  }

  data = {
    "MINIO_IDENTITY_OPENID_CONFIG_URL"    = "http://keycloak.keycloak:80/auth/realms/${keycloak_realm.minio_realm.id}/.well-known/openid-configuration"
    "MINIO_IDENTITY_OPENID_CLIENT_ID"     = keycloak_openid_client.openid_client.client_id
    "MINIO_IDENTITY_OPENID_CLIENT_SECRET" = keycloak_openid_client.openid_client.client_secret
    "MINIO_IDENTITY_OPENID_REDIRECT_URI"  = "http://${kubernetes_service.minio_loadbalancer.metadata[0].name}.${kubernetes_service.minio_loadbalancer.metadata[0].namespace}/oauth_callback"
  }
}

resource "kubernetes_secret" "minio_initial_user" {
  metadata {
    name      = "minio-initial-user"
    namespace = "minio-gateway"
  }

  data = {
    "username" = "admin"
    "password" = random_string.keycloak_minio_user_password.result
  }
}
