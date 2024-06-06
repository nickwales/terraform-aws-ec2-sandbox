job "windows-legacy" {

  constraint {
    attribute = "${attr.kernel.name}"
    value     = "windows"
  }

  group "windows-legacy" {
    count = 1
    network {
      port "http" {
        to = 8080
        static = 8080
      }
    }

    service {
      name = "helloworld"
      port = "http"

      check {
        type     = "tcp"
        interval = "30s"
        timeout  = "5s"
       
      } 
    }

    task "windows-helloworld" {
      driver = "docker"
      config {
        image = "mcr.microsoft.com/dotnet/samples:aspnetapp"
        image_pull_timeout = "21m"
        ports = ["http"]       
      }
    }
  }
}