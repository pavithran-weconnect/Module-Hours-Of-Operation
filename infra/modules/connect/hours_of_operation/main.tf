resource "awscc_connect_hours_of_operation" "this" {
  instance_arn = var.instance_arn
  name         = var.name
  description  = var.description
  time_zone    = var.time_zone

  config = [
    for c in var.config : {
      day = c.day
      start_time = {
        hours   = c.start_hours
        minutes = c.start_minutes
      }
      end_time = {
        hours   = c.end_hours
        minutes = c.end_minutes
      }
    }
  ]

  hours_of_operation_overrides = [
    for ov_name, ov in var.overrides : {
      override_name        = ov_name
      override_description = try(ov.override_description, null)
      override_type        = ov.override_type
      effective_from       = ov.effective_from
      effective_till       = ov.effective_till

      override_config = ov.override_config == null ? null : [
        for oc in ov.override_config : {
          day = oc.day
          start_time = {
            hours   = oc.start_hours
            minutes = oc.start_minutes
          }
          end_time = {
            hours   = oc.end_hours
            minutes = oc.end_minutes
          }
        }
      ]
    }
  ]
}
