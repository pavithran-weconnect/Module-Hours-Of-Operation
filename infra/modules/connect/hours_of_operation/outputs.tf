output "id" {
  value = awscc_connect_hours_of_operation.this.id
}

output "arn" {
  value = awscc_connect_hours_of_operation.this.hours_of_operation_arn
}

# The Connect "HoursOfOperationId" used in flow JSON is the UUID at the end of the ARN.
output "connect_hours_of_operation_id" {
  value = element(
    split("/", awscc_connect_hours_of_operation.this.hours_of_operation_arn),
    length(split("/", awscc_connect_hours_of_operation.this.hours_of_operation_arn)) - 1
  )
}

output "name" {
  value = awscc_connect_hours_of_operation.this.name
}
