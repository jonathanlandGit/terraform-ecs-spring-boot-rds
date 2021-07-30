resource "aws_ecs_cluster" "main" {
  name = "sb-cluster"
}

data "template_file" "springboot-ecs" {
  template = file("templates/ecs/production_app.json")

  vars = {
    app_image      = "${var.app_image}"
    fargate_cpu    = "${var.fargate_cpu}"
    fargate_memory = "${var.fargate_memory}"
    aws_region     = "${var.aws_region}"
    app_port       = "${var.app_port}"
    db_hostname    = "${aws_db_instance.mysql.endpoint}"
    db_port        = "${var.db_port}"
    db_name        = "${var.db_name}"
    db_username    = "${var.db_username}"
    db_password    = "${aws_ssm_parameter.secret.value}"
  }
}

resource "aws_ecs_task_definition" "app" {
  family = "sb-app-task"
  # execution_role_arn       = var.ecs_task_execution_role
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.springboot-ecs.rendered
}

resource "aws_ecs_service" "main" {
  name            = "sb-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = ["${aws_security_group.ecs_tasks.id}"]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = "sb-app"
    container_port   = var.app_port
  }

  depends_on = [
    "aws_alb_listener.front_end",
  ]
}
