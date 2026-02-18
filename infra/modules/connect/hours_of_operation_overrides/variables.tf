variable "instance_id" {
  type        = string
  description = "Amazon Connect instance id"
}

variable "hours_of_operation_id" {
  type        = string
  description = "Hours of Operation id to attach overrides to"
}

variable "overrides" {
  type = map(object({
    description    = optional(string)
    effective_from = string
    effective_till = string
    mode           = string # "CLOSED" or "OPENED"
    config = optional(list(object({
      day           = string
      start_hours   = number
      start_minutes = number
      end_hours     = number
      end_minutes   = number
    })))
  }))
  description = "Override definitions"
}

variable "tags" {
  type        = map(string)
  description = "Tags (reserved for future extension)"
  default     = {}
}
