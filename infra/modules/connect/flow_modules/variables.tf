variable "instance_id" {
  type        = string
  description = "Amazon Connect instance id"
}

variable "tags" {
  type        = map(string)
  description = "Tags (not applied to contact flow modules currently)"
  default     = {}
}

variable "hours_of_operation_ids_by_key" {
  type        = map(string)
  description = "Map of hoo_key => hours of operation ID (UUID) used inside flow module JSON"
}

variable "flow_modules" {
  type = map(object({
    name        = string
    description = string
    file_path   = string
    hoo_key     = string
  }))
  description = "Flow modules to deploy"
}
