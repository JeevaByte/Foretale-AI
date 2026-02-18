# EventBridge Module Outputs

output "event_bus_arn" {
  description = "ARN of the event bus"
  value = var.eventbus_name != "default" ? aws_cloudwatch_event_bus.main[0].arn : data.aws_cloudwatch_event_bus.default[0].arn
}

output "event_bus_name" {
  description = "Name of the event bus"
  value = var.eventbus_name != "default" ? aws_cloudwatch_event_bus.main[0].name : var.eventbus_name
}

output "rule_arns" {
  description = "Map of rule names to ARNs"
  value = {
    for k, v in aws_cloudwatch_event_rule.main : k => v.arn
  }
}

output "rule_names" {
  description = "Map of rule names"
  value = keys(aws_cloudwatch_event_rule.main)
}

output "target_ids" {
  description = "Map of target IDs"
  value = keys(aws_cloudwatch_event_target.main)
}