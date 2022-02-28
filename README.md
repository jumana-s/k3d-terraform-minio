# k3d-terraform-minio

# Setup

1. Install [k3d](https://k3d.io/v5.3.0/#installation)
2. Install [task](https://taskfile.dev/#/installation)
3. Run `task install`
4. Run `task k3d:start`
   - Optional: run `k9s` to see your cluster
5. Run `task helm:setup`
6. Run `task keycloak:install`
7. Add `kubectl get secret -n keycloak keycloak -o jsonpath="{.data.admin-password}" | base64 -d` and add value to tfvars like `keycloak_admin_password = $value`
8. Run `task terraform:init`
9. Run `task terraform:plan`
10. Run `task terraform:apply`
