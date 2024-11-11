resource "kubernetes_secret" "secret_food" {
  metadata {
    name = "secret-food"
  }

  type = "Opaque"

  data = {
    APPLICATION_VERSION              = var.image_version
    APPLICATION_DATABASE_VERSION     = "latest"
    APPLICATION_PORT                 = var.app_port
    SPRING_DATASOURCE_USERNAME       = var.db_username
    SPRING_DATASOURCE_PASSWORD       = var.db_password
    ENABLE_FLYWAY                    = var.enable_flyway
    FOOD_CLIENTE_VERSION             = var.food_cliente_image_version
    FOOD_CLIENTE_PORT                = var.food_cliente_app_port
    FODD_CLIENTE_DATASOURCE_USERNAME = var.food_cliente_db_username
    FOOD_CLIENTE_DATASOURCE_PASSWORD = var.food_cliente_db_password
    # FOOD_PRODUTO_VERSION             = var.food_produto_image_version
    # FOOD_PRODUTO_PORT                = var.food_produto_app_port
    # FOOD_PRODUTO_DATASOURCE_USERNAME = var.food_produto_db_username # TODO: Aqui vai ser o NOSql
    # FOOD_PRODUTO_DATASOURCE_PASSWORD = var.food_produto_db_password
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "kubernetes_config_map" "cm_food" {
  metadata {
    name = "cm-food"
  }

  # TODO: Quando tivermos as configurações de banco, precisamos adaptar aqui
  data = {
    SPRING_DATASOURCE_URL         = "jdbc:mysql://${var.db_host}:3306/${var.db_name}"
    SPRING_CLIENTE_DATASOURCE_URL = "jdbc:mysql://${var.food_cliente_db_host}:3306/${var.food_cliente_db_name}"
    SPRING_PRODUTO_DATASOURCE_URL = "NOSQL CONNECTION" # TODO: Aqui vai ser o NOSql
  }

  lifecycle {
    prevent_destroy = false
  }
}


# FOOD APP
resource "kubernetes_deployment" "deployment_food_app" {
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
          image = "${var.image_username}/${var.image_name}:${var.image_version}"

          resources {
            requests = {
              memory : "512Mi"
              cpu : "500m"
            }
            limits = {
              memory = "1Gi"
              cpu    = "1"
            }
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.cm_food.metadata[0].name
            }
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.secret_food.metadata[0].name
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

  depends_on = [aws_eks_node_group.food_node_group]
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

# FOOD CLIENTE
resource "kubernetes_deployment" "deployment_food_cliente" {
  metadata {
    name      = "deployment-food-cliente"
    namespace = var.kubernetes_namespace
  }

  spec {
    selector {
      match_labels = {
        app = "deployment-food-cliente"
      }
    }

    template {
      metadata {
        labels = {
          app = "deployment-food-cliente"
        }
      }

      spec {
        toleration {
          key      = "key"
          operator = "Equal"
          value    = "value"
          effect   = "NoSchedule"
        }

        container {
          name  = "deployment-food-cliente-container"
          image = "${var.image_username}/${var.image_name}:${var.image_version}" # TODO laf - mudar

          resources {
            requests = {
              memory : "512Mi"
              cpu : "500m"
            }
            limits = {
              memory = "1Gi"
              cpu    = "1"
            }
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.cm_food.metadata[0].name
            }
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.secret_food.metadata[0].name
            }
          }

          port {
            container_port = var.food_cliente_app_port
          }
        }
      }
    }
  }

  depends_on = [aws_eks_node_group.food_node_group]
}

resource "kubernetes_service" "food_cliente_service" {
  metadata {
    name      = "service-food-cliente"
    namespace = var.kubernetes_namespace
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type" : "nlb",
      "service.beta.kubernetes.io/aws-load-balancer-scheme" : "internal",
      "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled" : "true"
    }
  }
  spec {
    selector = {
      app = "deployment-food-cliente"
    }
    port {
      port        = var.food_cliente_app_port
      target_port = var.food_cliente_app_port
    }
    type = "LoadBalancer"
  }
}

resource "kubernetes_ingress_v1" "food_cliente_ingress" {
  metadata {
    name      = "ingress-food-cliente"
    namespace = var.kubernetes_namespace
  }

  spec {
    default_backend {
      service {
        name = kubernetes_service.food_cliente_service.metadata[0].name
        port {
          number = kubernetes_service.food_cliente_service.spec[0].port[0].port
        }
      }
    }
  }
}

data "kubernetes_service" "food_cliente_service_data" {
  metadata {
    name      = kubernetes_service.food_cliente_service.metadata[0].name
    namespace = kubernetes_service.food_cliente_service.metadata[0].namespace
  }
}

# FOOD PRODUTO
# resource "kubernetes_deployment" "deployment_food_produto" {
#   metadata {
#     name      = "deployment-food-produto"
#     namespace = var.kubernetes_namespace
#   }

#   spec {
#     selector {
#       match_labels = {
#         app = "deployment-food-produto"
#       }
#     }

#     template {
#       metadata {
#         labels = {
#           app = "deployment-food-produto"
#         }
#       }

#       spec {
#         toleration {
#           key      = "key"
#           operator = "Equal"
#           value    = "value"
#           effect   = "NoSchedule"
#         }

#         container {
#           name  = "deployment-food-produto-container"
#           image = "${var.image_username}/${var.image_name}:${var.image_version}" # TODO laf - mudar

#           resources {
#             requests = {
#               memory : "512Mi"
#               cpu : "500m"
#             }
#             limits = {
#               memory = "1Gi"
#               cpu    = "1"
#             }
#           }

#           env_from {
#             config_map_ref {
#               name = kubernetes_config_map.cm_food.metadata[0].name
#             }
#           }

#           env_from {
#             secret_ref {
#               name = kubernetes_secret.secret_food.metadata[0].name
#             }
#           }

#           port {
#             container_port = var.food_produto_app_port
#           }
#         }
#       }
#     }
#   }

#   depends_on = [aws_eks_node_group.food_node_group]
# }

# resource "kubernetes_service" "food_produto_service" {
#   metadata {
#     name      = "service-food-produto"
#     namespace = var.kubernetes_namespace
#     annotations = {
#       "service.beta.kubernetes.io/aws-load-balancer-type" : "nlb",
#       "service.beta.kubernetes.io/aws-load-balancer-scheme" : "internal",
#       "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled" : "true"
#     }
#   }
#   spec {
#     selector = {
#       app = "deployment-food-produto"
#     }
#     port {
#       port        = var.food_produto_app_port
#       target_port = var.food_produto_app_port
#     }
#     type = "LoadBalancer"
#   }
# }

# resource "kubernetes_ingress_v1" "food_produto_ingress" {
#   metadata {
#     name      = "ingress-food-produto"
#     namespace = var.kubernetes_namespace
#   }

#   spec {
#     default_backend {
#       service {
#         name = kubernetes_service.food_produto_service.metadata[0].name
#         port {
#           number = kubernetes_service.food_produto_service.spec[0].port[0].port
#         }
#       }
#     }
#   }
# }

# data "kubernetes_service" "food_produto_service_data" {
#   metadata {
#     name      = kubernetes_service.food_produto_service.metadata[0].name
#     namespace = kubernetes_service.food_produto_service.metadata[0].namespace
#   }
# }
