job "demo-webapp_02" {
  datacenters = ["aws-us-east-2"]

  region = "global"

  group "demo_02" {
    count = 2

    constraint {
      attribute = "${node.class}"
      value     = "app"
    }
       
    network {
      port "http" {
        to = -1
      }
    }

    scaling {
      enabled = true
      min     = 1
      max     = 4

      policy {
        evaluation_interval = "2s"
        cooldown            = "5s"

        check "cpu_usage" {
          source = "prometheus"
          query  = "avg(nomad_client_allocs_cpu_total_percent{task='server'})"
          strategy "target-value" {
            target = 10
          }
        }
      }
    }

    service {
      name = "demo-webapp"
      port = "http"
      provider = "nomad"
    }

    task "server" {
      env {
        PORT    = "${NOMAD_PORT_http}"
        NODE_IP = "${NOMAD_IP_http}"
      }

      driver = "docker"

      config {
        image = "hashicorp/demo-webapp-lb-guide"
        ports = ["http"]
      }

    }
  }
}