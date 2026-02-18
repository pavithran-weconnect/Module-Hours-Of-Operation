variable "instance_id" {
  type        = string
  description = "Amazon Connect instance id"
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

variable "tags" {
  type        = map(string)
  description = "Tags (also applied by provider default_tags; kept for future extension)"
  default     = {}
}
