# k3d-terraform-minio

# Setup

## Requirements

1. Install [k3d](https://k3d.io/v5.3.0/#installation)
2. Install [task](https://taskfile.dev/#/installation)

3. Run `task deploy`
4. Port forward keycloak on port 8080
5. Add `kubectl get secret -n keycloak keycloak -o jsonpath="{.data.admin-password}" | base64 -d` and add value to .tfvars like `keycloak_admin_password = $value`
6. Run `kubectl get svc keycloak -n keycloak -o yaml | yq e '.status.loadBalancer.ingress[0].ip' -` and copy the IP address
7. Run `sudo vim /etc/hosts` and add line: `$IP_ADDRESS keycloak.keycloak`
8. Run `task terraform:init`
9. Run `task terraform:plan`
10. Run `task terraform:apply`
11. Run `kubectl get svc minio -n minio-gateway -o yaml | yq e '.status.loadBalancer.ingress[0].ip' -` and copy the IP address
12. `sudo vim /etc/hosts` and add line: `$IP_ADDRESS minio.minio-gateway`
13. Open http://minio.minio-gateway in a browser and login using:

- admin
- value of `kubectl get secret minio-initial-user -n minio-gateway -o jsonpath={".data.password"} | base64 -d`

## OR (still being tested)

Run `bash script.sh`
