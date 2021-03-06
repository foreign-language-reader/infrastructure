# Required for horizontal pod autoscaling to work
# TODO update this location when a new home for this chart is found.
# resource "helm_release" "metrics_server" {
#   name       = "metrics-server"
#   repository = "https://kubernetes-charts.storage.googleapis.com"
#   chart      = "metrics-server"
#   version    = "2.11.4"
# }

# Logging configuration
# Every node has a log collection agent that posts logs to elasticsearch

resource "random_password" "fluent_elasticsearch_password" {
  length      = 32
  special     = false
  min_numeric = 10
}

resource "helm_release" "fluentd_elasticsearch" {
  name       = "fluentd"
  repository = "https://kokuwaio.github.io/helm-charts"
  chart      = "fluentd-elasticsearch"
  version    = "11.6.2"

  values = [file("${path.module}/fluentd.yml")]

  set_sensitive {
    name  = "elasticsearch.auth.password"
    value = random_password.fluent_elasticsearch_password.result
  }
}

resource "helm_release" "prometheus_operator" {
  name       = "prometheus"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "kube-prometheus"
  version    = "3.3.2"
}

resource "helm_release" "sematext_logagent" {
  name       = "sematext"
  repository = "https://cdn.sematext.com/helm-charts"
  chart      = "sematext-agent"
  version    = "1.0.35"

  set {
    name  = "region"
    value = "US"
  }

  set_sensitive {
    name  = "logsToken"
    value = var.sematext_index_name
  }
}

# resource "kubernetes_manifest" "api_prometheus" {
#   provider = kubernetes-alpha
#   manifest = yamldecode(file("${path.module}/api_prometheus.yml"))

#   depends_on = [helm_release.prometheus_operator]
# }