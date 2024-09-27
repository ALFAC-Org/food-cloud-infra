resource "kubernetes_secret" "secret_food" {
  metadata {
    name = "secret-food"
  }

  type = "Opaque"

  data = {
    APPLICATION_VERSION          = var.image_version
    APPLICATION_DATABASE_VERSION = "latest"
    APPLICATION_PORT             = var.app_port
    SPRING_DATASOURCE_USERNAME   = var.db_username
    SPRING_DATASOURCE_PASSWORD   = var.db_password
    ENABLE_FLYWAY                = var.enable_flyway
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
    SPRING_DATASOURCE_URL = "jdbc:mysql://${var.db_host}:3306/${var.db_name}"
  }

  lifecycle {
    prevent_destroy = false
  }
}

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

# resource "kubernetes_service" "food_app_service" {
#   metadata {
#     name      = "service-food-app"
#     namespace = var.kubernetes_namespace
#     annotations = {
#       "service.beta.kubernetes.io/aws-load-balancer-type" : "nlb",
#       "service.beta.kubernetes.io/aws-load-balancer-scheme" : "internal",
#       "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled" : "true"
#     }
#   }
#   spec {
#     selector = {
#       app = "deployment-food-app"
#     }
#     port {
#       port        = var.app_port
#       target_port = var.app_port
#     }
#     type = "LoadBalancer"
#   }
# }

resource "kubernetes_service" "food_app_service" {
  metadata {
    name      = "service-food-app"
    namespace = var.kubernetes_namespace
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type" : "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-scheme" : "internal"
      "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled" : "true"
    }
  }

  spec {
    selector = {
      app = "deployment-food-app"
    }

    port {
      port        = var.app_port # Porta exposta externamente
      target_port = var.app_port # Porta onde o app está rodando no pod
      node_port   = 30080        # NodePort (usado pelo Load Balancer)
    }

    type = "NodePort"
  }
}

# Obter IPs ou IDs das instâncias do Kubernetes (suposição de EC2)
data "aws_instance" "kubernetes_nodes" {
  filter {
    name   = "tag:eks:cluster-name"
    values = [var.cluster_name]
  }
}

# Criar o NLB
resource "aws_lb" "nlb_food_app" {
  name               = "nlb-food-app"
  internal           = true
  load_balancer_type = "network"
  subnets = [
    aws_subnet.food_public_subnet_1.id,
    aws_subnet.food_public_subnet_2.id
  ]
  enable_cross_zone_load_balancing = true
}

# Criar o Target Group para o NLB
resource "aws_lb_target_group" "food_app_target_group" {
  name     = "tg-food-app"
  port     = 30080 # Porta NodePort exposta nos nós
  protocol = "TCP"
  vpc_id   = aws_vpc.food_vpc.id

  health_check {
    protocol = "TCP"
    port     = "traffic-port"
  }
}

# Anexar as instâncias do Kubernetes ao Target Group
resource "aws_lb_target_group_attachment" "food_app_attachment" {
  for_each         = data.aws_instance.kubernetes_nodes.id
  target_group_arn = aws_lb_target_group.food_app_target_group.arn
  target_id        = each.value
  port             = 30080 # Porta NodePort
}

# Criar um listener para o NLB
resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb_food_app.arn
  port              = 8080 # Porta onde o tráfego externo será recebido
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.food_app_target_group.arn
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
