locals {
  validated = {
    for k, v in var.flow_modules : k => merge(v, {
      hours_of_operation_arn = lookup(var.hours_of_operation_arns_by_key, v.hoo_key, null)
    })
  }
}

# Fail fast if any flow module references an unknown hoo_key
resource "null_resource" "validate_hoo_key" {
  for_each = {
    for k, v in local.validated : k => v
    if v.hours_of_operation_arn == null
  }

  lifecycle {
    precondition {
      condition     = false
      error_message = "Flow module '${each.key}' references unknown hoo_key='${each.value.hoo_key}'. Valid keys: ${join(", ", keys(var.hours_of_operation_arns_by_key))}"
    }
  }
}

resource "aws_connect_contact_flow_module" "this" {
  for_each = local.validated

  instance_id = var.instance_id
  name        = each.value.name
  description = each.value.description

  content = templatefile(each.value.file_path, {
    hours_of_operation_arn = each.value.hours_of_operation_arn
  })
}
