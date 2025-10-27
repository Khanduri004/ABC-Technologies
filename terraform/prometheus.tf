# Create monitoring namespace
#resource "kubernetes_namespace" "prometheus_monitoring" {
 # metadata {
   # name = "prometheus-monitoring"
  #}

   #depends_on = [module.eks]
#}

# Install kube-prometheus-stack
#resource "helm_release" "kube_prometheus_stack" {
 # name       = "kube-prometheus-stack"
  #repository = "https://prometheus-community.github.io/helm-charts"
  #chart      = "kube-prometheus-stack"
  #version    = "45.6.0"

  #namespace = kubernetes_namespace.prometheus_monitoring.metadata[0].name

  #values = [
   # <<-YAML
    #grafana:
     # adminPassword: "StrongPasswordHere"
      #service:
       # type: LoadBalancer
    #prometheus:
     # prometheusSpec:
       # retention: 7d
    #kubeControllerManager:
     # enabled: false
    #nodeExporter:
     # enabled: true
    #kube-state-metrics:
     # enabled: true
   # YAML
  #]
#}