data "aws_connect_instance" "this" {
  instance_alias = var.connect_instance_alias
}

module "hours_of_operation" {
  source       = "../../modules/connect/hours_of_operation"
  instance_arn = data.aws_connect_instance.this.arn

  name        = var.hours_of_operation.name
  description = var.hours_of_operation.description
  time_zone   = var.hours_of_operation.time_zone
  config      = var.hours_of_operation.config

  overrides = var.hours_of_operation_overrides
  tags      = var.tags
}

module "flow_modules" {
  source      = "../../modules/connect/flow_modules"
  instance_id = data.aws_connect_instance.this.id

  hours_of_operation_ids_by_key = {
    pm_hours = module.hours_of_operation.connect_hours_of_operation_id
  }

  flow_modules = var.flow_modules
  tags         = var.tags
}

output "connect_instance_id" {
  value = data.aws_connect_instance.this.id
}

output "hours_of_operation_id" {
  value = module.hours_of_operation.connect_hours_of_operation_id
}

output "flow_module_ids" {
  value = module.flow_modules.flow_module_ids
}
