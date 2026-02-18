# EventBridge Module

This module sets up AWS EventBridge infrastructure for the ForeTale application, enabling event-driven architecture patterns.

## Features

- Custom event bus creation
- Configurable event rules with patterns
- Multiple target support per rule
- Environment-specific naming
- Comprehensive tagging

## Usage

```hcl
module "eventbridge" {
  source        = "./modules/eventbridge"
  environment   = var.environment
  eventbus_name = var.eventbus_name
  
  event_rules = {
    user_events = {
      description = "Capture user-related events"
      event_pattern = jsonencode({
        source      = ["com.foretale.application"],
        detail-type = ["User.Created", "User.Updated", "User.Deleted"]
      })
      enabled = true
      targets = {
        user_processing_lambda = {
          name     = "UserEventProcessor"
          arn      = "arn:aws:lambda:eu-west-2:442426872653:function:UserEventProcessor-${var.environment}"
          role_arn = module.iam.lambda_role_arn
        }
      }
    }
  }
  
  tags = {
    Environment = var.environment
    Project     = "foretale"
    ManagedBy   = "terraform"
  }
}
```

## Variables

- `environment` - Environment name (dev, staging, prod)
- `eventbus_name` - Name of the custom event bus
- `event_rules` - Map of event rules to create
- `tags` - Tags to apply to resources

## Outputs

- `event_bus_arn` - ARN of the event bus
- `event_bus_name` - Name of the event bus
- `rule_arns` - Map of rule names to ARNs
- `rule_names` - Map of rule names
- `target_ids` - Map of target IDs

## Event Schema

See [EVENT_SCHEMA.md](EVENT_SCHEMA.md) for details on event formats used in the application.