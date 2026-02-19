# data "aws_connect_instance" "this" {
#   instance_alias = var.connect_instance_alias
# }

# locals {
#   awscc_tags = [
#     for k, v in var.tags : { key = k, value = v }
#   ]

#   base_config = [
#     for c in var.hours_of_operation.config : {
#       day = c.day
#       start_time = { hours = c.start_hours, minutes = c.start_minutes }
#       end_time   = { hours = c.end_hours,   minutes = c.end_minutes }
#     }
#   ]
# }

# resource "awscc_connect_hours_of_operation" "this" {
#   instance_arn = data.aws_connect_instance.this.arn
#   name         = var.hours_of_operation.name
#   description  = var.hours_of_operation.description
#   time_zone    = var.hours_of_operation.time_zone
#   config       = local.base_config
#   tags         = local.awscc_tags
# }

# output "connect_instance_id" {
#   value = data.aws_connect_instance.this.id
# }

# output "hours_of_operation_arn" {
#   value = awscc_connect_hours_of_operation.this.hours_of_operation_arn
# }

# # UUID used by Connect APIs / flows
# output "hours_of_operation_id" {
#   value = element(
#     split("/", awscc_connect_hours_of_operation.this.hours_of_operation_arn),
#     length(split("/", awscc_connect_hours_of_operation.this.hours_of_operation_arn)) - 1
#   )
# }

# # For pipeline to consume overrides input easily
# output "overrides_json" {
#   value = jsonencode(var.hours_of_operation_overrides)
# }
