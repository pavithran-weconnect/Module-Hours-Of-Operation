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
  description = "Tags"
  default = {
    Project     = "Module-Hours-Of-Operation"
    ManagedBy   = "Terraform"
    Environment = "dev"
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

# Overrides are NOT created by Terraform resource (awscc update is flaky).
# We manage overrides using AWS CLI in pipeline.
variable "hours_of_operation_overrides" {
  type = map(object({
    description    = optional(string)
    effective_from = string # YYYY-MM-DD (Connect expects date-only)
    effective_till = string # YYYY-MM-DD
    override_type  = string # "OPEN" or "CLOSED"

    # must be non-empty for Connect/CloudControl-like validation; we enforce it here
    override_config = list(object({
      day           = string
      start_hours   = number
      start_minutes = number
      end_hours     = number
      end_minutes   = number
    }))

    # Optional recurrence (passed to CLI)
    recurrence = optional(object({
      frequency             = string
      interval              = optional(number)
      by_month              = optional(list(number))
      by_month_day          = optional(list(number))
      by_weekday_occurrence = optional(list(number))
    }))
  }))

  default = {}
}
