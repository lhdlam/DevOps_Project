locals {
  prefix = "${var.project_name}_${var.project_env}"
}

resource "aws_ssm_maintenance_window" "start_instances" {
  name     = "${local.prefix}-start-instances"
  duration = var.duration
  cutoff   = var.cutoff
  schedule = var.schedule_cron
  schedule_timezone = var.schedule_timezone

  depends_on = [ var.resource_group ]
}

resource "aws_ssm_maintenance_window_target" "start_instance_target" {
  window_id     = "${aws_ssm_maintenance_window.start_instances.id}"
  name          = "${local.prefix}-start-instance-target"
  description   = "start-instance: ${var.schedule_cron}, timezone: ${var.schedule_timezone}"
  resource_type = "RESOURCE_GROUP"

  targets {
    key = "resource-groups:Name"
    values = ["${var.resource_group.name}"]
  }
  targets {
    key    = "resource-groups:ResourceTypeFilters"
    values = ["AWS::EC2::Instance"]
  }
}

resource "aws_ssm_maintenance_window_task" "start_instance_task" {
  max_concurrency  = 2
  max_errors       = 1
  priority         = 1
  service_role_arn = "${var.automation_service_role_arn}"
  task_arn         = "AWS-StartEC2Instance"
  task_type        = "AUTOMATION"
  window_id        = aws_ssm_maintenance_window.start_instances.id

  targets {
    key    = "WindowTargetIds"
    values = [ aws_ssm_maintenance_window_target.start_instance_target.id ]
  }

  task_invocation_parameters {
    automation_parameters {
      parameter {
        name   = "InstanceId"
        values = ["{{RESOURCE_ID}}"]
      }
      parameter {
        name   = "AutomationAssumeRole"
        values = ["${var.automation_assume_role.arn}"]
      }
    }
  }
}
