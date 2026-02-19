locals {
  base_config = [
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

  overrides = [
    for ov_name, ov in var.overrides : {
      override_name        = ov_name
      override_description = try(ov.override_description, null)
      override_type        = ov.override_type

      # AWSCC expects date-only strings (YYYY-MM-DD)
      effective_from = ov.effective_from
      effective_till = ov.effective_till

      # AWSCC complains if override_config is not configured.
      # So we always send [] when it is not provided.
      override_config = (
        try(ov.override_config, null) == null
        ? []
        : [
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
      )

      # Optional recurrence support (maps to AWSCC recurrence_config)
      recurrence_config = (
        try(ov.recurrence, null) == null
        ? null
        : {
            recurrence_pattern = {
              frequency            = ov.recurrence.frequency
              interval             = try(ov.recurrence.interval, 1)
              by_month             = try(ov.recurrence.by_month, null)
              by_month_day         = try(ov.recurrence.by_month_day, null)
              by_weekday_occurrence = try(ov.recurrence.by_weekday_occurrence, null)
            }
          }
      )
    }
  ]
}

resource "awscc_connect_hours_of_operation" "this" {
  instance_arn = var.instance_arn
  name         = var.name
  description  = var.description
  time_zone    = var.time_zone

  config = local.base_config

  hours_of_operation_overrides = local.overrides
}
