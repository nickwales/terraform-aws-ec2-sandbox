module "eks_cluster_primary" {
    # source = "github.com/nickwales/terraform-module-aws-eks?ref=0.1.5"
    source = "/Users/nwales/checkouts/github.com/nickwales/terraform-module-aws-eks"
    name   = var.name
    region = var.region
    
    vpc_id          = module.vpc.vpc_id
    public_subnets  = module.vpc.public_subnets
    private_subnets = module.vpc.private_subnets

    desired_size = 4
    instance_type = "t3.medium"

    create_kms_key = true

    aws_caller_identity = "arn:aws:iam::068591307351:role/aws_nwales_test-developer"
    
}
