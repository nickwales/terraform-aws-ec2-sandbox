# module "tgw" {
#   source  = "terraform-aws-modules/transit-gateway/aws"
#   version = "~> 2.10"

#   name        = var.name
#   description = "TGW for routing"

#   enable_auto_accept_shared_attachments = true

#   vpc_attachments = {
#     vpc = {
#       vpc_id       = module.vpc.vpc_id
#       subnet_ids   = module.vpc.private_subnets
#       dns_support  = true
#       ipv6_support = true

#       tgw_routes = [
#         {
#           destination_cidr_block = "30.0.0.0/16"
#         },
#         {
#           blackhole = true
#           destination_cidr_block = "40.0.0.0/20"
#         }
#       ]
#     }
#   }

#   ram_allow_external_principals = true
#   #ram_principals = ["068591307351"]

#   tags = {
#     Purpose = var.name
#   }
# }