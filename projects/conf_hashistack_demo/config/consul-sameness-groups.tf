resource "consul_config_entry" "sameness_group_default" {
  kind = "sameness-group"
  name = "failover"  
  partition = "default"     

  config_json = jsonencode({
    Partition = "default"
    DefaultForFailover = true
    IncludeLocal       = true
    Members = [
      # { Peer = "${var.peer}" },
      { Partition = "database" }
    ]
  })
}

resource "consul_config_entry" "sameness_group_database" {
  kind      = "sameness-group"
  name      = "failover"    
  partition = "database"   

  config_json = jsonencode({
    Partition = "database"
    DefaultForFailover = true
    IncludeLocal       = true
    Members = [
      { Partition = "default" }
    ]
  })
}
