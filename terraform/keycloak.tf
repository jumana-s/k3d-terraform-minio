
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
  #claim_value_type = JSON
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
  #attributes = {
  #  key = "value"
  #}
}

# I had to get the role ID by exporting it from the Keycloak UI as JSON
# Creating this resource may fail, as this resource already exists in keycloak. 
# In order to resolve this:
# 1. We found the resource within Keycloak UI in the exported json.
# 2. Next, we took the id field's value for default-roles-minio, and ran the below command using the id.
#   terraform import keycloak_role.minio_admin_role minio/<ROLE ID>
# 3. After running this command, we ran `terraform plan` to observe the 'composite_roles' that were triggered to update.
# 4. Copy the list of composite roles with a minus sign into the below resource, and then terraform plan and apply.
# resource "keycloak_role" "minio_admin_role" {
#   realm_id        = keycloak_realm.minio_realm.id
#   name            = "default-roles-minio"
#   description     = "$${role_default-roles}"
#   composite_roles = [
#     keycloak_role.minio_client_role.id,
#     "6b6dab55-7c44-4e1c-b048-ed8402972fc0",
#     "974423a2-5444-42f0-a492-623c8cceeae7",
#     "980626d3-6523-4e02-9a54-d0f642dc0a64",
#     "f221d6ab-0ea2-454f-a571-32c5d5c66c41",
#   ]

#attributes = {
#  key = "value"
#}
# }


resource "kubernetes_secret" "minio_oidc_config" {
  metadata {
    name      = "minio-oidc-config"
    namespace = "minio-gateway"
  }

  data = {
    "MINIO_IDENTITY_OPENID_CONFIG_URL"    = "http://keycloak.keycloak:80/auth/realms/${keycloak_realm.minio_realm.id}/.well-known/openid-configuration"
    "MINIO_IDENTITY_OPENID_CLIENT_ID"     = keycloak_openid_client.openid_client.client_id
    "MINIO_IDENTITY_OPENID_CLIENT_SECRET" = keycloak_openid_client.openid_client.client_secret
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
