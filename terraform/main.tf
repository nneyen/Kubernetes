resource "kubectl_manifest" "deployment" {
    yaml_body = <<YAML
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
        image: nneyen/hello-world
        ports:
        - containerPort: 3000
YAML
  
}

resource "kubectl_manifest" "service" {
  yaml_body = <<YAML
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
  labels:
    name: myapp-service
    app: myapp
spec:
 type: NodePort
 ports:
   - port: 3000
     targetPort: 3000
     nodePort: 30004
 selector:
    app: myapp
YAML
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