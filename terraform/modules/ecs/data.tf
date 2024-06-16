
data "aws_iam_role" "existing_ecs_task_execution_role" {
  name = var.ecs_task_execution_role_name
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
