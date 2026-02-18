output "override_ids" {
  value = { for k, v in aws_connect_hours_of_operation_override.this : k => v.id }
}

output "override_arns" {
  value = { for k, v in aws_connect_hours_of_operation_override.this : k => v.arn }
}
