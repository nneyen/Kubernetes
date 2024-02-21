
# Deploy a Kubernetes Cluster with KinD and Setup Monitoring and Obervability

## Overview
This repository contains scripts and configurations to deploy a Kubernetes cluster locally using KIND (Kubernetes in Docker), along with a simple Express.js application, Dockerization of the app, Kubernetes deployment manifests, Terraform scripts for deployment, and setting up monitoring and observability using Kube-prometheus-stack.

## Prerequisites
Make sure you have the following tools installed:
- Docker
- Terraform
- Kubernetes
- Helm

## Setup Instructions
Follow these steps to set up and deploy the project
1. Clone this repository
```
git clone https://github.com/nneyen/Kubernetes.git
cd Kubernetes

```

### Deploy KIND Cluster
Run the Bash script to install and deploy a KIND cluster locally:
```
./kind.sh
```
### Build and Dockerize the App:
Navigate to the `myapp` directory and run:
```
docker build -t your-dockerhub-username/your-app-name .
docker push your-dockerhub-username/your-app-name

```

### Deploy App to Kubernetes with Terraform:
Navigate to the `terraform` directory and Terraform scripts to deploy the app and monitoring stack:
```
cd terraform 
terraform init
terraform apply
```
## Directory Structure
- `kind.sh`: Bash script to deploy a KIND cluster.
- `myapp`: Contains simple Express.js application.
- `Dockerfile`: Dockerfile to dockerize the app.
- `terraform/`: Terraform scripts to deploy app to Kubernetes, and setup monitoring using kube-prometheus-stack. 