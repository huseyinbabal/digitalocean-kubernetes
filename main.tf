provider "helm" {
  kubernetes {
    config_path = digitalocean_kubernetes_cluster.keptn.kube_config
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
  repository = "https://charts.keptn.sh"
  chart = "keptn"
  name  = "keptn"

  depends_on = [digitalocean_kubernetes_cluster.keptn]
}
