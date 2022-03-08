# k3d-terraform-minio

# Setup

## Requirements

1. Install [k3d](https://k3d.io/v5.3.0/#installation)
2. Install [task](https://taskfile.dev/#/installation)

## Steps

1. Run `task deploy`. It will print the MinIO credentials.

2. Open http://minio.minio-gateway in a browser and login using the credentials. If you forget them, use

> task password:minio

## Creating Buckets

Due to [some work done in the console UI](https://github.com/minio/console/blob/9c63bad6ee07a59a74dcd9769f45db1bc36899b5/portal-ui/src/screens/Console/Buckets/ListBuckets/ListBuckets.tsx#L197), creating buckets through the UI while using OPA is not possible.
For the time being, you can:

1. port-forward the minio pod in the minio namespace
2. get the login credentials by running `kubectl get secret minio -n minio -o json | jq -r '.data | to_entries | map({(.key): .value | @base64d}) | add'`
3. create buckets

The newly created bucket(s) will appear in http://minio.minio-gateway/buckets
