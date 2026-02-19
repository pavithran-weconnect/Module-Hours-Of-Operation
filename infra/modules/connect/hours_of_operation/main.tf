locals {
  awscc_tags = [
    for k, v in var.tags : { key = k, value = v }
  ]

  base_config = [
    for c in var.config : {
      day = c.day
      start_time = { hours = c.start_hours, minutes = c.start_minutes }
      end_time   = { hours = c.end_hours,   minutes = c.end_minutes }
    }
  ]

  overrides = [
    for ov_name in sort(keys(var.overrides)) : (
      {
        override_name        = ov_name
        override_description = try(var.overrides[ov_name].override_description, null)
        override_type        = upper(var.overrides[ov_name].override_type)

        effective_from = var.overrides[ov_name].effective_from
        effective_till = var.overrides[ov_name].effective_till

        override_config = [
          for oc in var.overrides[ov_name].override_config : {
            day = oc.day
            start_time = { hours = oc.start_hours, minutes = oc.start_minutes }
            end_time   = { hours = oc.end_hours,   minutes = oc.end_minutes }
          }
        ]

        recurrence_config = (
          try(var.overrides[ov_name].recurrence, null) == null
          ? null
          : {
              recurrence_pattern = merge(
                {
                  frequency = upper(var.overrides[ov_name].recurrence.frequency)
                  interval  = try(var.overrides[ov_name].recurrence.interval, 1)
                },
                try(var.overrides[ov_name].recurrence.by_month, null) == null
                  ? {}
                  : { by_month = var.overrides[ov_name].recurrence.by_month },
                try(var.overrides[ov_name].recurrence.by_month_day, null) == null
                  ? {}
                  : { by_month_day = var.overrides[ov_name].recurrence.by_month_day },
                try(var.overrides[ov_name].recurrence.by_weekday_occurrence, null) == null
                  ? {}
                  : { by_weekday_occurrence = var.overrides[ov_name].recurrence.by_weekday_occurrence }
              )
            }
        )
      }
    )
  ]
}

resource "awscc_connect_hours_of_operation" "this" {
  instance_arn = var.instance_arn
  name         = var.name
  description  = var.description
  time_zone    = var.time_zone

  config = local.base_config

  hours_of_operation_overrides = local.overrides

  tags = local.awscc_tags
}
