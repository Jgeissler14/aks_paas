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
    file("./helm/argo/argocd-bootstrap-values.yaml"),
  ]
}

resource "helm_release" "app_of_apps" {
  name       = "app-of-apps"
  namespace  = "argocd"
  repository = "https://github.com/jgeissler14/aks_paas/helm/argo/workloads/templates"
  chart      = "workloads"
}

# resource "kubernetes_namespace" "cert-manager" {
#   depends_on = [data.azurerm_kubernetes_cluster.default]

#   metadata {
#     name = "cert-manager"
#   }
# }

# Cert Manager
# resource "helm_release" "cert_manager" {
#   name       = "cert-manager"
#   namespace  = "cert-manager"
#   repository = "https://charts.jetstack.io"
#   chart      = "cert-manager"
#   version    = "v1.16.2"
#   skip_crds  = true

#   # values = [
#   #   file("./helm/cert-manager/cert-manager-values.yaml"),
#   # ]
# }