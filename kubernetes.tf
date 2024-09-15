resource "kubernetes_deployment" "deployment_food_app" {
  # depends_on = [aws_eks_node_group.food_node_group]
  metadata {
    name      = "deployment-food-app"
    namespace = var.kubernetes_namespace
  }

  spec {
    selector {
      match_labels = {
        app = "deployment-food-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "deployment-food-app"
        }
      }

      spec {
        // Prevent error:
        // 0/2 nodes are available: 2 node(s) were unschedulable. 
        // preemption: 0/2 nodes are available: 2 
        // Preemption is not helpful for scheduling.
        toleration {
          key      = "key"
          operator = "Equal"
          value    = "value"
          effect   = "NoSchedule"
        }

        container {
          name  = "deployment-food-app-container"
          image = "${var.image_name}:${var.image_version}"

          resources {
            requests = {
              memory: "512Mi"
              cpu: "500m"
            }
            limits = {
              memory = "1Gi"
              cpu    = "1"
            }
          }

          port {
            container_port = var.app_port
          }

          # liveness_probe {
          #   http_get {
          #     path = "/api/v2/health-check"
          #     port = var.app_port
          #   }
          #   initial_delay_seconds = 30
          #   period_seconds        = 3
          # }
        }
      }
    }
  }
}

resource "kubernetes_service" "food_app_service" {
  metadata {
    name      = "service-food-app"
    namespace = var.kubernetes_namespace
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type" : "nlb",
      "service.beta.kubernetes.io/aws-load-balancer-scheme" : "internal",
      "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled" : "true"
    }
  }
  spec {
    selector = {
      app = "deployment-food-app"
    }
    port {
      port        = var.app_port
      target_port = var.app_port
    }
    type = "LoadBalancer"
  }
}

# Failed to create Ingress 'default/ingress-food-app' because: the server could not find the requested resource (post ingresses.extensions)
# So let's use kubernetes_ingress_v1 instead of kubernetes_ingress
resource "kubernetes_ingress_v1" "food_app_ingress" {
  metadata {
    name      = "ingress-food-app"
    namespace = var.kubernetes_namespace
  }

  spec {
    default_backend {
      service {
        name = kubernetes_service.food_app_service.metadata[0].name
        port {
          number = kubernetes_service.food_app_service.spec[0].port[0].port
        }
      }
    }
  }
}

data "kubernetes_service" "food_app_service_data" {
  metadata {
    name      = kubernetes_service.food_app_service.metadata[0].name
    namespace = kubernetes_service.food_app_service.metadata[0].namespace
  }
}
