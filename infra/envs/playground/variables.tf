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
  description = "Default tags applied to all resources (via provider default_tags)"
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
  }))

  description = "Map of override name -> override settings"

  default = {
    "Maintenance" = {
      override_description = "Closed - Maintenance window (placeholder)"
      effective_from       = "2026-02-16T00:00:00Z"
      effective_till       = "2031-12-31T00:00:00Z"
      override_type        = "CLOSED"
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

  description = "Map of flow module key -> flow module settings (+ hoo_key)"

  default = {
    pm_hours_module = {
      name        = "PM Hours Module"
      description = "PM Hours module - playground plan only"
      file_path   = "../../../assets/connect/flow-modules/pm-hours-module.json"
      hoo_key     = "pm_hours"
    }
  }
}
