resource "aws_ecs_cluster" "consul-aws" {
  name = "consul-aws"
}

resource "aws_ecs_service" "client" {
  name            = "client"
  cluster         = aws_ecs_cluster.consul-aws.id
  task_definition = aws_ecs_task_definition.client.arn
  desired_count   = 1
  launch_type     = "FARGATE"
 # iam_role        = aws_iam_role.foo.arn
 # depends_on      = [aws_iam_role_policy.foo]

  network_configuration {
    subnets = module.vpc.public_subnets
    assign_public_ip = true
    security_groups = [aws_security_group.example_client_app.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "client"
    container_port   = 9090
  }

  service_registries {
    registry_arn = aws_service_discovery_service.client.arn
  }
}


resource "aws_ecs_task_definition" "client" {
  family = "service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  #execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  #task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn

  cpu                      = 1024
  memory                   = 2048

  container_definitions = jsonencode([
    {
      name      = "client"
      image     = "docker.mirror.hashicorp.services/nicholasjackson/fake-service:v0.25.2"
      cpu       = 100
      memory    = 128
      essential = true
      environment = [
        {"name":"LISTEN_ADDR", "value": "0.0.0.0:9090"}, 
        {"name": "NAME", "value": "FrontEnd - running on ECS"},
        {"name": "MESSAGE", "value": "FrontEnd - running on ECS"},
        {"name": "UPSTREAM_URIS", "value": "http://api.service.consul:9200"},
      ]


      portMappings = [
        {
          containerPort = 9090
          hostPort      = 9090
        }
      ]
    }
  ])
}