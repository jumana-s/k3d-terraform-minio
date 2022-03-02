#!/bin/bash

# create cluster and install metallb and keycloak
# task deploy

# wait for keycloak to start
while [[ $(kubectl get pods -l app.kubernetes.io/name=keycloak -n keycloak -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]
do 
  echo "waiting for keycloak" && sleep 30; 
done

# add admin secret to terraform.tfvars
export psw=$(kubectl get secret --namespace keycloak keycloak -o jsonpath="{.data.admin-password}" | base64 --decode)
echo "keycloak_admin_password = \"$psw\"" >> terraform/terraform.tfvars

# port-forward keycloak
kubectl port-forward statefulset/keycloak -n keycloak 8080:8080 &

# add keycloak to hosts file
export IP_ADDRESS=$(kubectl get svc keycloak -n keycloak -o yaml | yq e '.status.loadBalancer.ingress[0].ip' -)
echo "$IP_ADDRESS keycloak.keycloak" | sudo tee -a /etc/hosts

# apply terraform 
task terraform:init
# task terraform:plan
task terraform:apply

# add minio to host file
export IP_ADDRESS=$(kubectl get svc minio -n minio-gateway -o yaml | yq e '.status.loadBalancer.ingress[0].ip' -)
echo "$IP_ADDRESS minio.minio-gateway" | sudo tee -a /etc/hosts

# display login method
export admin_psw=$(kubectl get secret minio-initial-user -n minio-gateway -o jsonpath={".data.password"} | base64 -d)
echo -e "----- \n\n Open http://minio.minio-gateway in a browser and login using: \n  username = user  \n  password = $admin_psw \n\n"
