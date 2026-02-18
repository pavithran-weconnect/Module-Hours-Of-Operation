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
variable "overrides" {
  type = map(object({
    override_description = optional(string)
    effective_from       = string # YYYY-MM-DD
    effective_till       = string # YYYY-MM-DD
    override_type        = string

    override_config = optional(list(object({
      day           = string
      start_hours   = number
      start_minutes = number
      end_hours     = number
      end_minutes   = number
    })))
  }))
  description = "Map of override name -> override definition"
  default     = {}
}
