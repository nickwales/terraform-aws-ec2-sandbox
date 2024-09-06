terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region
}


for i in $(seq 1 100000);
do
    nomad namespace apply test-namespace-$i
done


uccessfully applied namespace "test-namespace-26810"!
Successfully applied namespace "test-namespace-26811"!
Successfully applied namespace "test-namespace-26812"!
Successfully applied namespace "test-namespace-26813"!
Successfully applied namespace "test-namespace-26814"!
Successfully applied namespace "test-namespace-26815"!
Successfully applied namespace "test-namespace-26816"!
Successfully applied namespace "test-namespace-26817"!
Successfully applied namespace "test-namespace-26818"!
Successfully applied namespace "test-namespace-26819"!
Successfully applied namespace "test-namespace-26820"!
Successfully applied namespace "test-namespace-26821"!
Successfully applied namespace "test-namespace-26822"!
Successfully applied namespace "test-namespace-26823"!
Successfully applied namespace "test-namespace-26824"!
Successfully applied namespace "test-jra