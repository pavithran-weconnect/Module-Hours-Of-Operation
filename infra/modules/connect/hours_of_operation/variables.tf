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

variable "config" {
  type = list(object({
    day           = string
    start_hours   = number
    start_minutes = number
    end_hours     = number
    end_minutes   = number
  }))
  description = "Weekly schedule config"
}

# Overrides embedded via AWSCC resource
#
# IMPORTANT:
# - effective_from/effective_till MUST be YYYY-MM-DD (no time)
# - time windows go into override_config (start/end)
# - recurrence is optional; when provided, it maps to recurrence_config.recurrence_pattern.*
#
variable "overrides" {
  type = map(object({
    override_description = optional(string)
    effective_from       = string # YYYY-MM-DD
    effective_till       = string # YYYY-MM-DD
    override_type        = string # e.g. CLOSED / OPENED (as per Connect)

    override_config = optional(list(object({
      day           = string
      start_hours   = number
      start_minutes = number
      end_hours     = number
      end_minutes   = number
    })))

    # Optional recurrence (weekly/monthly/yearly etc.)
    recurrence = optional(object({
      frequency            = string           # WEEKLY | MONTHLY | YEARLY
      interval             = optional(number) # default 1
      by_month             = optional(list(number))
      by_month_day         = optional(list(number))
      by_weekday_occurrence = optional(list(number))
    }))
  }))

  description = "Map of override name -> override definition"
  default     = {}
}
