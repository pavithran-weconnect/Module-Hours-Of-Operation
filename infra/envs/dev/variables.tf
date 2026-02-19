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
# Hours of Operation inputs
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

# -------------------------
# Overrides (AWSCC embedded)
# effective_* must be YYYY-MM-DD (no time)
# Timing goes into override_config.
# Recurrence supported via recurrence block.
# -------------------------
variable "hours_of_operation_overrides" {
  type = map(object({
    override_description = optional(string)
    effective_from       = string
    effective_till       = string
    override_type        = string

    override_config = optional(list(object({
      day           = string
      start_hours   = number
      start_minutes = number
      end_hours     = number
      end_minutes   = number
    })))

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
    # 1) CLOSED full day
    "Holiday - Full Day Closed" = {
      override_description = "Closed all day"
      effective_from       = "2026-12-25"
      effective_till       = "2026-12-25"
      override_type        = "CLOSED"
      override_config      = []
    }

    # 2) CLOSED hours window (close 13:00-14:00 on weekdays in March)
    "Lunch Closure March" = {
      override_description = "Closed during lunch (Mon-Fri)"
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

    # 3) OPENED (open on Saturday 10:00-14:00 during June)
    "Campaign Saturday Opening" = {
      override_description = "Open Saturday for campaign"
      effective_from       = "2026-06-01"
      effective_till       = "2026-06-30"
      override_type        = "OPENED"
      override_config = [
        { day = "SATURDAY", start_hours = 10, start_minutes = 0, end_hours = 14, end_minutes = 0 }
      ]
    }

    # 4) Weekly recurrence (like UI) - CLOSED hours every week 09:00-17:00 for all days
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

    # 5) Monthly recurrence - CLOSED on 1st day of every month (full day)
    "Monthly First Day Closed" = {
      override_description = "Closed on the 1st of every month"
      effective_from       = "2026-01-01"
      effective_till       = "2026-12-31"
      override_type        = "CLOSED"
      override_config      = []
      recurrence = {
        frequency    = "MONTHLY"
        interval     = 1
        by_month_day = [1]
      }
    }

    # 6) Yearly recurrence - CLOSED every Christmas (full day)
    "Yearly Christmas Closed" = {
      override_description = "Christmas Day closed yearly"
      effective_from       = "2026-01-01"
      effective_till       = "2035-12-31"
      override_type        = "CLOSED"
      override_config      = []
      recurrence = {
        frequency    = "YEARLY"
        interval     = 1
        by_month     = [12]
        by_month_day = [25]
      }
    }

    # 7) Long maintenance - CLOSED (full day) across many days
    "Maintenance Window" = {
      override_description = "Closed - Maintenance"
      effective_from       = "2026-02-16"
      effective_till       = "2026-02-20"
      override_type        = "CLOSED"
      override_config      = []
    }
  }
}

# -------------------------
# Flow modules to deploy
# hoo_key must match main.tf map: "pm_hours"
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
