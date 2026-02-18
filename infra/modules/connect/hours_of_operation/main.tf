resource "aws_connect_hours_of_operation" "this" {
  instance_id  = var.instance_id
  name         = var.name
  description  = var.description
  time_zone    = var.time_zone

  dynamic "config" {
    for_each = var.config
    content {
      day = config.value.day

      start_time {
        hours   = config.value.start_hours
        minutes = config.value.start_minutes
      }

      end_time {
        hours   = config.value.end_hours
        minutes = config.value.end_minutes
      }
    }
  }
}
