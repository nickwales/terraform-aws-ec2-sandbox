job "traefik" {
  datacenters = ["dc1"]
  type        = "system"
  namespace   = "operations"

  constraint {
    attribute = "${attr.kernel.name}"
    value = "linux"
  }

  update {
    max_parallel = 1
    stagger      = "45s"
  }

    // Traefik should be prioritized ahead of other jobs.
  priority = 75

  group "traefik" {
    network {
      mode = "bridge"
      port "http" { 
        static = 80
        to     = 80
      }         
      port "api" {
        static = 8080
        to     = 8080
      }
      port "ping" {
        static = 8085
        to     = 8085
      }   
      port "asp" {
        static = 81
        to     = 81
      }         
      port "static" {
        static = 82
        to     = 82
      }
      port "framework" {
        static = 83
        to     = 83
      }      

    }

    ephemeral_disk {
      migrate = true
      size    = 105
      sticky  = true
    }

    service {
      name = "traefik"

      tags = [
        "traefik.enable=true"
      ]

      check {
        name     = "alive"
        type     = "http"
        port     = "ping"
        path     = "/ping"
        interval = "10s"
        timeout  = "2s"
      }
    }

    service {
      name = "traefik-admin"
      port = "api"
      tags = [
        // "traefik.enable=true",
        // "traefik.http.routers.api.entrypoints=api",
        // "traefik.http.routers.api.rule=(Host(`traefik.service.consul`) || Host(`localhost`) || Host(`${attr.unique.network.ip-address}`) Host(`http://hashistack-dc1-fc49215ba4c79ff6.elb.us-east-1.amazonaws.com`)) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))",
        // "traefik.http.routers.api.service=api@internal"          
      ]

      check {
        name     = "alive"
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "traefik" {
      driver = "docker"

      config {
        image = "traefik"
        args  = ["--configFile=local/traefik.yaml"]
        ports = ["http", "api", "ping", "metrics"]
      }

      resources {
          cpu    = 100 # MHz
          memory = 100 # MB
      }

      template {
        destination = "local/traefik.yaml"
        data = <<DATA
providers:
  consulCatalog:
    endpoint:
      address: {{ env "attr.unique.network.ip-address" }}:8500
      token: root
    exposedByDefault: true
accessLog:
  filePath: "/local/access.log"
  format: json
  fields:
    defaultMode: keep
    names:
      ClientUsername: drop
    headers:
      defaultMode: keep   
global:
  checkNewVersion: true
  sendAnonymousUsage: true
api:
  dashboard: true
  insecure: true
  debug: true
entryPoints:
  http:
    address: ":80"
  asp:
    address: ":81"
  static:
    address: ":82"
  framework:
    address: ":83"    
  ping:
    address: ":8085"
ping:
  entryPoint: "ping"
log:
  level: DEBUG
DATA
      }
    } 
  }
}
