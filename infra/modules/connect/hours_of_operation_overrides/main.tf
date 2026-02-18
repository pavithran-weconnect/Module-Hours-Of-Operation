locals {
  normalized = {
    for name, ov in var.overrides : name => merge(ov, {
      mode   = upper(ov.mode)
      config = try(ov.config, null)
    })
  }
}

resource "aws_connect_hours_of_operation_override" "this" {
  for_each = local.normalized

  instance_id           = var.instance_id
  hours_of_operation_id = var.hours_of_operation_id

  name        = each.key
  description = try(each.value.description, null)

  effective_from = each.value.effective_from
  effective_till = each.value.effective_till

  dynamic "config" {
    for_each = each.value.mode == "OPENED" && each.value.config != null ? each.value.config : []
    content {
      day = config.value.day

      start_time {
        hours   = config.value.start_hours
        minutes = config.value.start_minutes
      }

      end_time {
        hours   = config.value.end_hours
        minutes = config.value.end_minutes
      }
    }
  }
}
