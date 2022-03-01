# k3d-terraform-minio

# Setup

1. Install [k3d](https://k3d.io/v5.3.0/#installation)
2. Install [task](https://taskfile.dev/#/installation)
3. Run `task k3d:create`
4. Run `task k3d:start`
   - Optional: run `k9s` to see your cluster
5. Run `task helm:setup`
6. Get configmap values by running `docker network inspect -f '{{.IPAM.Config}}' k3d-minio-cluster`
   - add those values to the addresses section on configmap.yaml
7. Run `task metallb:instal`
8. Run `task keycloak:install`
9. Port forward keycloak on port 8080
10. Add `kubectl get secret -n keycloak keycloak -o jsonpath="{.data.admin-password}" | base64 -d` and add value to .tfvars like `keycloak_admin_password = $value`
11. Run `kubectl get svc keycloak -n keycloak -o yaml | yq e '.status.loadBalancer.ingress[0].ip' -` and copy the IP address
12. Run `sudo vim /etc/hosts` and add line: `$IP_ADDRESS keycloak.keycloak`
13. Run `task terraform:init`
14. Run `task terraform:plan`
15. Run `task terraform:apply`
16. Run `kubectl get svc minio -n minio-gateway -o yaml | yq e '.status.loadBalancer.ingress[0].ip' -` and copy the IP address
17. `sudo vim /etc/hosts` and add line: `$IP_ADDRESS minio.minio-gateway`
18. Open http://minio.minio-gateway in a browser and login using:

- admin
- value of `kubectl get secret minio-initial-user -n minio-gateway -o jsonpath={".data.password"} | base64 -d`
