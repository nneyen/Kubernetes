# Kubernetes
Summary. 
### Setup Kubernetes Cluster Using Kind

1. I wrote a bash script that deploys a [kind](https://kind.sigs.k8s.io/docs/user/quick-start/) cluster locally. It is straightforward if you know a bit of bash scripting and also read the documentation linked above

Here is a simple script for that 

```
#!/bin/bash

#specify the location where you want to install kind

INSTALL_DIR="/usr/local/bin"


#specify url make sure it is the right exec file for your system
KIND_URL="https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64"

#use the wget command to grap download kind from the url and then place it in the directory at /kind

wget -O $INSTALL_DIR/kind $KIND_URL

#make kind executable
chmod +x $INSTALL_DIR/kind 


#I added this check to see if installation was successful so I can create a cluster. 

if [ $? -eq 0 ]; then
    echo "Kind installed successfully!"

    echo "Creating a Log into docker and create Kind Cluster"

    docker login
    kind create cluster 
else
    echo "Error: Kind installation failed."
    exit 1
fi

```

> Tip 💡 : pulling the kinD node image from Docker Hub will require logging into docker hub. So before running the bash script, log in to docker hub. You could also include docker login command in your script


To run the script use the following command:
`sudo bash filename.sh`

Here is the output of the installation in progress 
```
+ INSTALL_DIR=/usr/local/bin
+ KIND_URL=https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64
+ wget -O /usr/local/bin/kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64
--2024-02-18 03:50:04--  https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64
Resolving kind.sigs.k8s.io (kind.sigs.k8s.io)... 2600:1f1c:471:9d00::c8, 2600:1f1c:446:4900::64, 13.57.148.141, ...

.
.
.
.
Login Succeeded
Docker login successful!
Creating Kind cluster ...
Creating cluster "kind" ...
 ✓ Ensuring node image (kindest/node:v1.29.2) 🖼 
 ✓ Preparing nodes 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
Set kubectl context to "kind-kind"
You can now use your cluster with:

kubectl cluster-info --context kind-kind

Have a question, bug, or feature request? Let us know! https://kind.sigs.k8s.io/#community 🙂
Kind cluster created successfully!

```


2. Next, I downloaded the kubeconfig for the cluster and stored it somewhere safe to be used later. 

First, I confirmed there was a cluster using the command : `kind get clusters`
Then I used this command:  `kind get kubeconfig --name my-cluster-name > $PATH/destination` , to download my kubeconfig file 

---

### Deploy a sample Node.js app using terraform
1. First I wrote a simple app in [express] (https://expressjs.com/en/starter/hello-world.html)

> Tip 💡: Remember to install express dependencies by running `npm install express`

2. Next, I wrote a DockerFile and pushed the app to dockerhub

Sample dockerfile:
```
FROM node:slim

WORKDIR /myapp

COPY . .

RUN npm install

CMD [ "node", "app.js" ]

EXPOSE 3000

```
build and tag the image : `docker build -t app_name .`

run the app to see if it works well : `docker run -p 3000:3000 app `

login to docker : `docker login`

push to dockerhub : `docker push yourusername/app_name`

3. Next I created a manifest file to deploy the app to the kind cluster, but I will be using terraform to deploy it in the next step

mine looks like this:
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: <link to your docker image in dockerhub>
        ports:
        - containerPort: <port>
```
The manifest file will be included in the terraform resource block. This is where your kubeconfig will come in handy.

4. Let's create terraform scripts to deploy the manifest file. 
first, terraform provider 

> NOTE : It is important to set your path to your kube config file , I spent a lot of time on this. 

Terraform provider can be found [here](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs)

```
provider "kubectl" {
  config_context_cluster = "your-cluster-name"
  config_path = "path/to/your/kubeconfig"
}
```
4b. Terraform resource block 
```
resource "kubectl_manifest" "deployment" {
    yaml_body = <<YAML
"your manifest goes here"
YAML  
}
```
4c. Setting environment variables: 
Initially when I checked kubectl version I got this error `The connection to the server localhost:8080 was refused - did you specify the right host or port?` and I also couldn't list pods or nodes. I realised it was because the environment variable for KUBECONFIG was not properly set. 

To set it use the following command `export KUBECONFIG=/path/to/your/kubeconfig`

4c. Run the following :
```
terraform plan
terraform apply

```
if your deployment is successfully deployed, you can run `kubectl get deployments` to see your deployments

> Just to be sure everything was working fine, I created a service that would allow expose my app to the outside world. I used `kubectl port-forward` to access the service from my local machine.

### Monitoring
I used kube-promethus stack and terraform helm provider to set up monitoring :

The helm provider  and resource block:
```
provider "helm" {
  kubernetes {
    config_context_cluster = "cluster-name"
    config_path = "your-config-path"
  }
}

resource "helm_release" "monitoring-stack" {
  name = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "kube-prometheus-stack"

  set {
    name = "prometheus.service.type"
    value = "NodePort"
  }

  set {
    name = "grafana.service.type"
    value = "NodePort"
  }
}

```
This will enable monitoring on grafana.

> To find your grafana's password use the folliwng command `kubectl get secret grafana-pod-name -o jsonpath="{.data.admin-password}" | base64 --decode`