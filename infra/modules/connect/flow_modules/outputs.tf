output "flow_module_ids" {
  value = { for k, v in aws_connect_contact_flow_module.this : k => v.id }
}

output "flow_module_arns" {
  value = { for k, v in aws_connect_contact_flow_module.this : k => v.arn }
}
