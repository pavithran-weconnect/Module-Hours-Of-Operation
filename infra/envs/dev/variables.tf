variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-2"
}

variable "connect_instance_alias" {
  type        = string
  description = "Amazon Connect instance alias"
  default     = "cms-demo-connect-general"
}

variable "tags" {
  type        = map(string)
  description = "Default tags applied to all resources (provider default_tags + AWSCC tags in module)"
  default = {
    Project     = "Module-Hours-Of-Operation"
    ManagedBy   = "Terraform"
    Environment = "dev"
  }
}

# -------------------------
# Base Hours of Operation (STANDARD schedule)
# -------------------------
variable "hours_of_operation" {
  type = object({
    name        = string
    description = string
    time_zone   = string
    config = list(object({
      day           = string
      start_hours   = number
      start_minutes = number
      end_hours     = number
      end_minutes   = number
    }))
  })

  description = "Hours of Operation definition"
  default = {
    name        = "PM Hours"
    description = "PM hours - managed by Terraform"
    time_zone   = "Europe/London"
    config = [
      { day = "MONDAY",    start_hours = 9, start_minutes = 0, end_hours = 17, end_minutes = 0 },
      { day = "TUESDAY",   start_hours = 9, start_minutes = 0, end_hours = 17, end_minutes = 0 },
      { day = "WEDNESDAY", start_hours = 9, start_minutes = 0, end_hours = 17, end_minutes = 0 },
      { day = "THURSDAY",  start_hours = 9, start_minutes = 0, end_hours = 17, end_minutes = 0 },
      { day = "FRIDAY",    start_hours = 9, start_minutes = 0, end_hours = 17, end_minutes = 0 }
    ]
  }
}

variable "hours_of_operation_overrides" {
  type = map(object({
    override_description = optional(string)
    effective_from       = string
    effective_till       = string
    override_type        = string

    override_config = list(object({
      day           = string
      start_hours   = number
      start_minutes = number
      end_hours     = number
      end_minutes   = number
    }))

    recurrence = optional(object({
      frequency             = string
      interval              = optional(number)
      by_month              = optional(list(number))
      by_month_day          = optional(list(number))
      by_weekday_occurrence = optional(list(number))
    }))
  }))

  description = "Map of override name -> override settings"
  default = {
    # -------------------------------------------------------
    # CLOSED full day examples (represented as 00:00-23:59)
    # -------------------------------------------------------
    "New Years Day" = {
      override_description = "Closed - New Years Day (full day)"
      effective_from       = "2026-01-01"
      effective_till       = "2026-01-01"
      override_type        = "CLOSED"
      override_config = [
        { day = "THURSDAY", start_hours = 0, start_minutes = 0, end_hours = 23, end_minutes = 59 }
      ]
    }

    "Good Friday" = {
      override_description = "Closed - Good Friday (full day)"
      effective_from       = "2026-04-03"
      effective_till       = "2026-04-03"
      override_type        = "CLOSED"
      override_config = [
        { day = "FRIDAY", start_hours = 0, start_minutes = 0, end_hours = 23, end_minutes = 59 }
      ]
    }

    "Easter Monday" = {
      override_description = "Closed - Easter Monday (full day)"
      effective_from       = "2026-04-06"
      effective_till       = "2026-04-06"
      override_type        = "CLOSED"
      override_config = [
        { day = "MONDAY", start_hours = 0, start_minutes = 0, end_hours = 23, end_minutes = 59 }
      ]
    }

    # NOTE: 2026-12-25 is FRIDAY, 2026-12-26 is SATURDAY
    "Christmas Day" = {
      override_description = "Closed - Christmas Day (full day)"
      effective_from       = "2026-12-25"
      effective_till       = "2026-12-25"
      override_type        = "CLOSED"
      override_config = [
        { day = "FRIDAY", start_hours = 0, start_minutes = 0, end_hours = 23, end_minutes = 59 }
      ]
    }

    "Boxing Day" = {
      override_description = "Closed - Boxing Day (full day)"
      effective_from       = "2026-12-26"
      effective_till       = "2026-12-26"
      override_type        = "CLOSED"
      override_config = [
        { day = "SATURDAY", start_hours = 0, start_minutes = 0, end_hours = 23, end_minutes = 59 }
      ]
    }

    # -------------------------------------------------------
    # CLOSED time-window (Lunch closure)
    # -------------------------------------------------------
    "Lunch Closure March" = {
      override_description = "Closed during lunch (Mon-Fri) 13:00-14:00"
      effective_from       = "2026-03-01"
      effective_till       = "2026-03-31"
      override_type        = "CLOSED"
      override_config = [
        { day = "MONDAY",    start_hours = 13, start_minutes = 0, end_hours = 14, end_minutes = 0 },
        { day = "TUESDAY",   start_hours = 13, start_minutes = 0, end_hours = 14, end_minutes = 0 },
        { day = "WEDNESDAY", start_hours = 13, start_minutes = 0, end_hours = 14, end_minutes = 0 },
        { day = "THURSDAY",  start_hours = 13, start_minutes = 0, end_hours = 14, end_minutes = 0 },
        { day = "FRIDAY",    start_hours = 13, start_minutes = 0, end_hours = 14, end_minutes = 0 }
      ]
    }

    # -------------------------------------------------------
    # OPEN (special opening hours)
    # -------------------------------------------------------
    "Campaign Saturday Opening" = {
      override_description = "Open Saturday 10:00-14:00"
      effective_from       = "2026-06-01"
      effective_till       = "2026-06-30"
      override_type        = "OPEN"
      override_config = [
        { day = "SATURDAY", start_hours = 10, start_minutes = 0, end_hours = 14, end_minutes = 0 }
      ]
    }

    # -------------------------------------------------------
    # WEEKLY recurrence example (like UI)
    # Closed every week 09:00-17:00 for all days, within date range
    # -------------------------------------------------------
    "Weekly Recurring Closed Window" = {
      override_description = "Recurring closed window 09:00-17:00 weekly"
      effective_from       = "2026-01-01"
      effective_till       = "2026-12-31"
      override_type        = "CLOSED"
      override_config = [
        { day = "MONDAY",    start_hours = 9, start_minutes = 0, end_hours = 17, end_minutes = 0 },
        { day = "TUESDAY",   start_hours = 9, start_minutes = 0, end_hours = 17, end_minutes = 0 },
        { day = "WEDNESDAY", start_hours = 9, start_minutes = 0, end_hours = 17, end_minutes = 0 },
        { day = "THURSDAY",  start_hours = 9, start_minutes = 0, end_hours = 17, end_minutes = 0 },
        { day = "FRIDAY",    start_hours = 9, start_minutes = 0, end_hours = 17, end_minutes = 0 },
        { day = "SATURDAY",  start_hours = 9, start_minutes = 0, end_hours = 17, end_minutes = 0 },
        { day = "SUNDAY",    start_hours = 9, start_minutes = 0, end_hours = 17, end_minutes = 0 }
      ]
      recurrence = {
        frequency = "WEEKLY"
        interval  = 1
      }
    }

    # -------------------------------------------------------
    # MONTHLY recurrence example: closed on 1st day of every month (full day)
    # CloudControl still needs override_config non-empty -> 00:00-23:59 on MONDAY
    # NOTE: For monthly/day-of-month recurrence, Connect applies it on the matching day,
    # override_config "day" may be ignored/validated differently by service.
    # If Connect rejects the day mismatch, we will switch to a minimal supported config.
    # -------------------------------------------------------
    "Monthly First Day Closed" = {
      override_description = "Closed on the 1st of every month (full day)"
      effective_from       = "2026-01-01"
      effective_till       = "2026-12-31"
      override_type        = "CLOSED"
      override_config = [
        { day = "MONDAY", start_hours = 0, start_minutes = 0, end_hours = 23, end_minutes = 59 }
      ]
      recurrence = {
        frequency    = "MONTHLY"
        interval     = 1
        by_month_day = [1]
      }
    }

    # -------------------------------------------------------
    # YEARLY recurrence example: Christmas every year (full day)
    # CloudControl needs override_config non-empty -> 00:00-23:59 on FRIDAY
    # -------------------------------------------------------
    "Yearly Christmas Closed" = {
      override_description = "Christmas Day closed yearly (full day)"
      effective_from       = "2026-01-01"
      effective_till       = "2035-12-31"
      override_type        = "CLOSED"
      override_config = [
        { day = "FRIDAY", start_hours = 0, start_minutes = 0, end_hours = 23, end_minutes = 59 }
      ]
      recurrence = {
        frequency    = "YEARLY"
        interval     = 1
        by_month     = [12]
        by_month_day = [25]
      }
    }

    # -------------------------------------------------------
    # Long maintenance across many days (full day closure)
    # -------------------------------------------------------
    "Maintenance Window" = {
      override_description = "Closed - Maintenance full day"
      effective_from       = "2026-02-16"
      effective_till       = "2031-12-31"
      override_type        = "CLOSED"
      override_config = [
        { day = "MONDAY",    start_hours = 0, start_minutes = 0, end_hours = 23, end_minutes = 59 },
        { day = "TUESDAY",   start_hours = 0, start_minutes = 0, end_hours = 23, end_minutes = 59 },
        { day = "WEDNESDAY", start_hours = 0, start_minutes = 0, end_hours = 23, end_minutes = 59 },
        { day = "THURSDAY",  start_hours = 0, start_minutes = 0, end_hours = 23, end_minutes = 59 },
        { day = "FRIDAY",    start_hours = 0, start_minutes = 0, end_hours = 23, end_minutes = 59 },
        { day = "SATURDAY",  start_hours = 0, start_minutes = 0, end_hours = 23, end_minutes = 59 },
        { day = "SUNDAY",    start_hours = 0, start_minutes = 0, end_hours = 23, end_minutes = 59 }
      ]
    }
  }
}

# -------------------------
# Flow modules to deploy
# hoo_key must match the key used in env main.tf map: "pm_hours"
# -------------------------
variable "flow_modules" {
  type = map(object({
    name        = string
    description = string
    file_path   = string
    hoo_key     = string
  }))

  description = "Map of flow module key -> flow module settings (+ hoo_key)"

  default = {
    pm_hours_module = {
      name        = "PM Hours Module"
      description = "PM Hours module - managed by Terraform"
      file_path   = "../../../assets/connect/flow-modules/pm-hours-module.json"
      hoo_key     = "pm_hours"
    }
  }
}
