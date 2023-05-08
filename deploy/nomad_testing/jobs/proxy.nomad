job "nginx_04" {
  datacenters = ["aws-us-east-2"]

  region = "global"

  group "nginx04" {
    count = 1

    constraint {
      attribute = "${node.class}"
      value     = "app"
    }

    network {
      port "http" {
        static = 80
      }
    }
    
    service {
      name = "nginx"
      port = "http"
      provider = "nomad"
    }

    task "nginx" {
      driver = "docker"

      config {
        image = "nginx"

        ports = ["http"]

        volumes = [
          "local/load-balancer.conf:/etc/nginx/conf.d/load-balancer.conf",
        ]
      }

      template {
        data = <<EOF
upstream backend.mlimache.com {
{{ range nomadService "demo-webapp" }}
  server {{ .Address }}:{{ .Port }};
{{ end }}
}

server {
   listen 80;

   access_log  /var/log/nginx/access.log;
   error_log   /var/log/nginx/error.log;

   location / {
      proxy_pass http://backend.mlimache.com;
   }
}

EOF

        destination   = "local/load-balancer.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
    }
  }
}