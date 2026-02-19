variable "instance_arn" {
  type        = string
  description = "Amazon Connect instance ARN"
}

variable "name" {
  type        = string
  description = "Hours of Operation name"
}

variable "description" {
  type        = string
  description = "Hours of Operation description"
  default     = ""
}

variable "time_zone" {
  type        = string
  description = "Time zone (e.g., Europe/London)"
}

variable "tags" {
  type        = map(string)
  description = "Tags as map(string); module converts to AWSCC tag format"
  default     = {}
}

variable "config" {
  type = list(object({
    day           = string
    start_hours   = number
    start_minutes = number
    end_hours     = number
    end_minutes   = number
  }))
  description = "Weekly schedule config"

  validation {
    condition = alltrue([
      for c in var.config :
      contains(["MONDAY","TUESDAY","WEDNESDAY","THURSDAY","FRIDAY","SATURDAY","SUNDAY"], c.day)
      && c.start_hours >= 0 && c.start_hours <= 23
      && c.end_hours >= 0 && c.end_hours <= 23
      && c.start_minutes >= 0 && c.start_minutes <= 59
      && c.end_minutes >= 0 && c.end_minutes <= 59
    ])
    error_message = "config: day must be MONDAY..SUNDAY and hours/minutes must be in valid ranges."
  }
}

# Overrides embedded via AWSCC resource
#
# IMPORTANT:
# - effective_from/effective_till MUST be YYYY-MM-DD (no time)
# - For timing: use override_config (it represents the time window for the override type)
# - recurrence is optional; when provided, it maps to AWSCC recurrence_config.recurrence_pattern.*
#
variable "overrides" {
  type = map(object({
    override_description = optional(string)
    effective_from       = string # YYYY-MM-DD
    effective_till       = string # YYYY-MM-DD

    # Use Connect schema values: typically "CLOSED" or "OPENED"
    override_type = string

    # Optional time windows. If omitted, module will send [] (AWSCC requires configured)
    override_config = optional(list(object({
      day           = string
      start_hours   = number
      start_minutes = number
      end_hours     = number
      end_minutes   = number
    })))

    # Optional recurrence support
    recurrence = optional(object({
      frequency             = string           # WEEKLY | MONTHLY | YEARLY
      interval              = optional(number) # default 1
      by_month              = optional(list(number)) # 1-12
      by_month_day          = optional(list(number)) # -1..31 (per AWSCC docs)
      by_weekday_occurrence = optional(list(number))
    }))
  }))
  description = "Map of override name -> override definition"
  default     = {}

  validation {
    condition = alltrue([
      for k, ov in var.overrides :
      length(k) >= 1
      && can(regex("^\\d{4}-\\d{2}-\\d{2}$", ov.effective_from))
      && can(regex("^\\d{4}-\\d{2}-\\d{2}$", ov.effective_till))
      && contains(["CLOSED","OPENED"], upper(ov.override_type))
    ])
    error_message = "overrides: effective_from/effective_till must be YYYY-MM-DD and override_type must be CLOSED or OPENED."
  }

  validation {
    condition = alltrue([
      for _, ov in var.overrides :
      (
        try(ov.override_config, null) == null
        ? true
        : alltrue([
            for c in ov.override_config :
            contains(["MONDAY","TUESDAY","WEDNESDAY","THURSDAY","FRIDAY","SATURDAY","SUNDAY"], c.day)
            && c.start_hours >= 0 && c.start_hours <= 23
            && c.end_hours >= 0 && c.end_hours <= 23
            && c.start_minutes >= 0 && c.start_minutes <= 59
            && c.end_minutes >= 0 && c.end_minutes <= 59
          ])
      )
    ])
    error_message = "overrides.override_config: day must be MONDAY..SUNDAY and hours/minutes must be in valid ranges."
  }

  validation {
    condition = alltrue([
      for _, ov in var.overrides :
      (
        try(ov.recurrence, null) == null
        ? true
        : (
            contains(["WEEKLY","MONTHLY","YEARLY"], upper(ov.recurrence.frequency))
            && try(ov.recurrence.interval, 1) >= 1
            && (
              try(ov.recurrence.by_month, null) == null
              ? true
              : alltrue([for m in ov.recurrence.by_month : m >= 1 && m <= 12])
            )
            && (
              try(ov.recurrence.by_month_day, null) == null
              ? true
              : alltrue([for d in ov.recurrence.by_month_day : d >= -1 && d <= 31 && d != 0])
            )
          )
      )
    ])
    error_message = "overrides.recurrence: frequency must be WEEKLY/MONTHLY/YEARLY; interval>=1; by_month 1-12; by_month_day -1..31 (not 0)."
  }
}
