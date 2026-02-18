# Add EventBridge module to the existing infrastructure

module "eventbridge" {
  source        = "./modules/eventbridge"
  environment   = var.environment
  eventbus_name = "foretale-event-bus"
  
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
    },
    
    project_events = {
      description = "Capture project-related events"
      event_pattern = jsonencode({
        source      = ["com.foretale.application"],
        detail-type = ["Project.Created", "Project.Updated", "Project.Deleted", "Project.Executed"]
      })
      enabled = true
      targets = {
        project_processing_lambda = {
          name     = "ProjectEventProcessor"
          arn      = "arn:aws:lambda:eu-west-2:442426872653:function:ProjectEventProcessor-${var.environment}"
          role_arn = module.iam.lambda_role_arn
        }
      }
    },
    
    data_quality_events = {
      description = "Capture data quality analysis events"
      event_pattern = jsonencode({
        source      = ["com.foretale.application"],
        detail-type = ["DataQuality.Analysis.Started", "DataQuality.Analysis.Completed", "DataQuality.Analysis.Failed"]
      })
      enabled = true
      targets = {
        data_quality_processing_lambda = {
          name     = "DataQualityEventProcessor"
          arn      = "arn:aws:lambda:eu-west-2:442426872653:function:DataQualityEventProcessor-${var.environment}"
          role_arn = module.iam.lambda_role_arn
        }
      }
    },
    
    report_events = {
      description = "Capture report generation events"
      event_pattern = jsonencode({
        source      = ["com.foretale.application"],
        detail-type = ["Report.Generated", "Report.Shared", "Report.Downloaded"]
      })
      enabled = true
      targets = {
        report_processing_lambda = {
          name     = "ReportEventProcessor"
          arn      = "arn:aws:lambda:eu-west-2:442426872653:function:ReportEventProcessor-${var.environment}"
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