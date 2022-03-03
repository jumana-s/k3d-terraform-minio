# k3d-terraform-minio

# Setup

## Requirements

1. Install [k3d](https://k3d.io/v5.3.0/#installation)
2. Install [task](https://taskfile.dev/#/installation)

## Steps

1. Run `task deploy`. It will print the MinIO credentials.

2. Open http://minio.minio-gateway in a browser and login using the credentials. If you forget them, use

> task password:minio
