variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "eventbus_name" {
  description = "Name of the custom event bus"
  type        = string
  default     = "foretale-event-bus"
}

variable "event_rules" {
  description = "Map of event rules to create"
  type = map(object({
    description     = string
    event_pattern   = string
    enabled         = bool
    targets = map(object({
      name                   = string
      arn                    = string
      role_arn               = string
      input                  = optional(string)
      input_path             = optional(string)
      input_transformer      = optional(map(string))
      retry_policy           = optional(map(number))
      dead_letter_config_arn = optional(string)
    }))
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Project = "foretale"
    ManagedBy = "terraform"
  }
}