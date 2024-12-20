// https://thomasdecaux.medium.com/deploy-a-kubernetes-gitops-ready-aks-terraform-argocd-193e61d19d05
locals {
  argocd_resources_labels = {
    "app.kubernetes.io/instance"  = "argocd"
    "argocd.argoproj.io/instance" = "argocd"
  }

  argocd_resources_annotations = {
    "argocd.argoproj.io/compare-options" = "IgnoreExtraneous"
    "argocd.argoproj.io/sync-options"    = "Prune=false,Delete=false"
  }
}

resource "kubernetes_namespace" "argocd" {
  depends_on = [data.azurerm_kubernetes_cluster.default]

  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.46.7"
  skip_crds  = true

  values = [
    file("./argo/argocd-bootstrap-values.yaml"),
  ]
}

# cert manager
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.16.2"
  skip_crds  = true
}