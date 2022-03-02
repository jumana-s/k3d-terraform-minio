# k3d-terraform-minio

# Setup

## Requirements

1. Install [k3d](https://k3d.io/v5.3.0/#installation)
2. Install [task](https://taskfile.dev/#/installation)


1. Run `task deploy`
2. Port forward keycloak on port 8080
3. Add `kubectl get secret -n keycloak keycloak -o jsonpath="{.data.admin-password}" | base64 -d` and add value to .tfvars like `keycloak_admin_password = $value`
4. Run `kubectl get svc keycloak -n keycloak -o yaml | yq e '.status.loadBalancer.ingress[0].ip' -` and copy the IP address
5. Run `sudo vim /etc/hosts` and add line: `$IP_ADDRESS keycloak.keycloak`
6. Run `task terraform:init`
7. Run `task terraform:plan`
8. Run `task terraform:apply`
9. Run `kubectl get svc minio -n minio-gateway -o yaml | yq e '.status.loadBalancer.ingress[0].ip' -` and copy the IP address
10. `sudo vim /etc/hosts` and add line: `$IP_ADDRESS minio.minio-gateway`
11. Open http://minio.minio-gateway in a browser and login using:

- admin
- value of `kubectl get secret minio-initial-user -n minio-gateway -o jsonpath={".data.password"} | base64 -d`
