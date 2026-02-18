data "aws_connect_instance" "this" {
  instance_alias = var.connect_instance_alias
}

module "hours_of_operations" {
  for_each    = var.hours_of_operations
  source      = "../../modules/connect/hours_of_operation"
  instance_id = data.aws_connect_instance.this.id

  name        = each.value.name
  description = each.value.description
  time_zone   = each.value.time_zone
  config      = each.value.config

  tags = var.tags
}

module "hours_of_operation_overrides" {
  for_each    = var.hours_of_operation_overrides_by_hoo
  source      = "../../modules/connect/hours_of_operation_overrides"
  instance_id = data.aws_connect_instance.this.id

  hours_of_operation_id = module.hours_of_operations[each.key].id
  overrides             = each.value

  tags = var.tags
}

module "flow_modules" {
  source      = "../../modules/connect/flow_modules"
  instance_id = data.aws_connect_instance.this.id

  hours_of_operation_arns_by_key = {
    for k, m in module.hours_of_operations : k => m.arn
  }

  flow_modules = var.flow_modules

  tags = var.tags
}

output "connect_instance_id" {
  value = data.aws_connect_instance.this.id
}

output "hours_of_operation_ids" {
  value = { for k, m in module.hours_of_operations : k => m.id }
}

output "flow_module_ids" {
  value = module.flow_modules.flow_module_ids
}
