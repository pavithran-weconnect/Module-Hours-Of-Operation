variable "instance_id" {
  type        = string
  description = "Amazon Connect instance id"
}

variable "hours_of_operation_arns_by_key" {
  type        = map(string)
  description = "Map of hoo_key -> Hours of Operation ARN"
}

variable "flow_modules" {
  type = map(object({
    name        = string
    description = string
    file_path   = string
    hoo_key     = string
  }))
  description = "Flow module definitions, each referencing a hoo_key"
}

variable "tags" {
  type        = map(string)
  description = "Tags (reserved for future extension)"
  default     = {}
}
