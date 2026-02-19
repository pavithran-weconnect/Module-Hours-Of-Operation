locals {
  rendered = {
    for k, v in var.flow_modules : k => {
      name        = v.name
      description = v.description
      file_path   = v.file_path
      hoo_id      = lookup(var.hours_of_operation_ids_by_key, v.hoo_key, null)

      content = templatefile(v.file_path, {
        hours_of_operation_id = lookup(var.hours_of_operation_ids_by_key, v.hoo_key, "")
      })
    }
  }

  invalid_hoo_key = {
    for k, v in local.rendered : k => v
    if v.hoo_id == null
  }
}

resource "terraform_data" "validate_hoo_key" {
  for_each = local.invalid_hoo_key

  lifecycle {
    precondition {
      condition     = length(keys(local.invalid_hoo_key)) == 0
      error_message = "Flow module '${each.key}' references unknown hoo_key. Valid keys: ${join(", ", keys(var.hours_of_operation_ids_by_key))}"
    }
  }
}

resource "terraform_data" "validate_json" {
  for_each = local.rendered

  lifecycle {
    precondition {
      condition     = can(jsondecode(each.value.content))
      error_message = "Rendered JSON for flow module '${each.key}' is invalid. Check placeholders/quotes in ${each.value.file_path}"
    }
  }
}

resource "aws_connect_contact_flow_module" "this" {
  for_each = local.rendered

  instance_id = var.instance_id
  name        = each.value.name
  description = each.value.description
  content     = each.value.content

  depends_on = [terraform_data.validate_json]
}
