job "service-on-windows" {

  datacenters = ["dc1"]
  type = "service"

  constraint {
    attribute = "${attr.kernel.name}"
    value = "windows"
  }

  group "service-on-windows" {
    count = 1

    network {
      port "http" {
        static = 9080
        to     = 9091
      }
    }

    service {
      name = "service-on-windows"
      port = "9090"

      check {       
        type     = "tcp"
        name     = "service-on-windows"
        interval = "30s"
        timeout  = "10s"
      }
    }



    task "service-on-windows" {
      driver = "raw_exec"

      artifact {
        source = "https://github.com/nicholasjackson/fake-service/releases/download/v0.26.2/fake_service_windows_amd64.zip"
      }

      config {
        command  = "fake-service.exe"      
      }

      env {
        NAME = "service-on-windows"
        MESSAGE = "Running on Windows"
        LISTEN_ADDR = "0.0.0.0:9091"
        test = "abc"
      }    
    }
  }
}


