provider "helm" {
  kubernetes {
    host  = digitalocean_kubernetes_cluster.keptn.endpoint
    token = digitalocean_kubernetes_cluster.keptn.kube_config[0].token
    cluster_ca_certificate = base64decode(
      digitalocean_kubernetes_cluster.keptn.kube_config[0].cluster_ca_certificate
    )
  }
}

resource "digitalocean_kubernetes_cluster" "keptn" {
  name   = "keptn"
  region = "nyc1"
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.26.3-do.0"

  node_pool {
    name       = "worker-pool"
    size       = "s-4vcpu-8gb"
    node_count = 2
  }
}

resource "helm_release" "keptn" {
  depends_on = [digitalocean_kubernetes_cluster.keptn]

  repository = "https://charts.keptn.sh"
  chart = "keptn"
  name  = "keptn"
  namespace = "keptn"
  create_namespace = true
}

resource "helm_release" "job-executor-service" {
  depends_on = [helm_release.keptn]

  chart = "https://github.com/keptn-contrib/job-executor-service/releases/download/0.3.0/job-executor-service-0.3.0.tgz"
  name  = "job-executor-service"
  namespace = "keptn-jes"
  create_namespace = true

  set {
    name  = "remoteControlPlane.autoDetect.enabled"
    value = "true"
  }

  set {
    name  = "subscription.pubsubTopic"
    value = "sh.keptn.event.remote-task.triggered"
  }

  set {
    name  = "remoteControlPlane.api.token"
    value = ""
  }

  set {
    name  = "remoteControlPlane.api.hostname"
    value = ""
  }

  set {
    name  = "remoteControlPlane.api.protocol"
    value = ""
  }
}
