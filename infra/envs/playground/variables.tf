variable "environment" {
  type        = string
  description = "Environment name"
  default     = "playground"
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
    Environment = "playground"
  }
}

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
    description = "PM hours - playground plan only"
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

  description = "Overrides examples for playground"
  default = {
    "Weekly Recurring Closed Window" = {
      override_description = "Recurring closed window 09:00-17:00 weekly"
      effective_from       = "2026-01-01"
      effective_till       = "2026-12-31"
      override_type        = "CLOSED"
      override_config = [
        { day = "MONDAY",  start_hours = 9, start_minutes = 0, end_hours = 17, end_minutes = 0 },
        { day = "TUESDAY", start_hours = 9, start_minutes = 0, end_hours = 17, end_minutes = 0 }
      ]
      recurrence = {
        frequency = "WEEKLY"
        interval  = 1
      }
    }

    "Maintenance Window" = {
      override_description = "Closed - Maintenance"
      effective_from       = "2026-02-16"
      effective_till       = "2026-02-20"
      override_type        = "CLOSED"
      override_config      = []
    }
  }
}

variable "flow_modules" {
  type = map(object({
    name        = string
    description = string
    file_path   = string
    hoo_key     = string
  }))

  description = "Flow modules map (+ hoo_key)"
  default = {
    pm_hours_module = {
      name        = "PM Hours Module"
      description = "PM Hours module - playground plan only"
      file_path   = "../../../assets/connect/flow-modules/pm-hours-module.json"
      hoo_key     = "pm_hours"
    }
  }
}
