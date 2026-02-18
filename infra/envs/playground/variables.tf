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

# -------------------------
# Multiple Hours of Operation
# -------------------------
variable "hours_of_operations" {
  type = map(object({
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
  }))
  description = "Map of key -> Hours of Operation definition"

  default = {
    pm_hours = {
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
}

# -------------------------
# Overrides per HOO (nested map)
# hours_of_operation_overrides_by_hoo = {
#   pm_hours = { "New Years Day" = {...}, ... }
#   ooh_hours = { ... }
# }
# -------------------------
variable "hours_of_operation_overrides_by_hoo" {
  type = map(
    map(object({
      description    = optional(string)
      effective_from = string
      effective_till = string
      mode           = string
      config = optional(list(object({
        day           = string
        start_hours   = number
        start_minutes = number
        end_hours     = number
        end_minutes   = number
      })))
    }))
  )

  description = "Nested map of HOO key -> override name -> override settings"

  default = {
    pm_hours = {
      "New Years Day" = {
        description    = "Closed - New Years Day"
        effective_from = "2026-01-01T00:00:00Z"
        effective_till = "2026-01-02T00:00:00Z"
        mode           = "CLOSED"
      }
      "Good Friday" = {
        description    = "Closed - Good Friday"
        effective_from = "2026-04-03T00:00:00Z"
        effective_till = "2026-04-04T00:00:00Z"
        mode           = "CLOSED"
      }
      "Easter Monday" = {
        description    = "Closed - Easter Monday"
        effective_from = "2026-04-06T00:00:00Z"
        effective_till = "2026-04-07T00:00:00Z"
        mode           = "CLOSED"
      }
      "Christmas Day" = {
        description    = "Closed - Christmas Day"
        effective_from = "2026-12-25T00:00:00Z"
        effective_till = "2026-12-26T00:00:00Z"
        mode           = "CLOSED"
      }
      "Boxing Day" = {
        description    = "Closed - Boxing Day"
        effective_from = "2026-12-26T00:00:00Z"
        effective_till = "2026-12-27T00:00:00Z"
        mode           = "CLOSED"
      }
      "Maintenance" = {
        description    = "Closed - Maintenance window (placeholder)"
        effective_from = "2026-02-16T00:00:00Z"
        effective_till = "2031-12-31T00:00:00Z"
        mode           = "CLOSED"
      }
    }
  }
}

# -------------------------
# Flow modules (map), each mapped to a HOO key
# -------------------------
variable "flow_modules" {
  type = map(object({
    name        = string
    description = string
    file_path   = string
    hoo_key     = string
  }))

  description = "Map of flow module key -> flow module settings (+ hoo_key to inject ARN)"

  default = {
    pm_hours_module = {
      name        = "PM Hours Module"
      description = "PM Hours module - playground plan only"
      file_path   = "../../../assets/connect/flow-modules/pm-hours-module.json"
      hoo_key     = "pm_hours"
    }
  }
}
