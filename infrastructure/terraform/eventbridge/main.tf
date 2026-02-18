# EventBridge Module

# Create custom event bus
resource "aws_cloudwatch_event_bus" "main" {
  count = var.eventbus_name != "default" ? 1 : 0
  name  = "${var.eventbus_name}-${var.environment}"

  tags = merge(var.tags, {
    Name = "${var.eventbus_name}-${var.environment}"
  })
}

# Create event rules
resource "aws_cloudwatch_event_rule" "main" {
  for_each = var.event_rules

  name        = "${each.key}-${var.environment}"
  description = each.value.description
  event_bus_name = var.eventbus_name != "default" ? aws_cloudwatch_event_bus.main[0].name : "default"
  event_pattern = each.value.event_pattern
  is_enabled    = each.value.enabled

  tags = merge(var.tags, {
    Name = "${each.key}-${var.environment}"
  })
}

# Create event targets
resource "aws_cloudwatch_event_target" "main" {
  for_each = {
    for rule_name, rule_config in var.event_rules : 
    "${rule_name}-${each.key}" => {
      rule_name = rule_name
      target_config = each.value
      target_key = each.key
    }
    if length(keys(rule_config.targets)) > 0
  }

  rule             = aws_cloudwatch_event_rule.main[each.value.rule_name].name
  event_bus_name   = var.eventbus_name != "default" ? aws_cloudwatch_event_bus.main[0].name : "default"
  target_id        = "${each.value.target_key}-${var.environment}"
  arn              = each.value.target_config.arn
  role_arn         = each.value.target_config.role_arn

  # Optional attributes
  input             = lookup(each.value.target_config, "input", null)
  input_path        = lookup(each.value.target_config, "input_path", null)
  retry_policy      = lookup(each.value.target_config, "retry_policy", null) != null ? jsonencode(each.value.target_config.retry_policy) : null
  dead_letter_config = lookup(each.value.target_config, "dead_letter_config_arn", null) != null ? {
    arn = each.value.target_config.dead_letter_config_arn
  } : null

  # Handle input_transformer separately if provided
  dynamic "input_transformer" {
    for_each = lookup(each.value.target_config, "input_transformer", null) != null ? [1] : []

    content {
      input_paths = each.value.target_config.input_transformer
      input_template = jsonencode(each.value.target_config.input_transformer)
    }
  }
}

# Data source to get the default event bus (if needed)
data "aws_cloudwatch_event_bus" "default" {
  count = var.eventbus_name == "default" ? 1 : 0
  name  = "default"
}