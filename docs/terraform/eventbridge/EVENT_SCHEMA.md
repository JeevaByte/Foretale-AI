# EventBridge Event Schemas

This document describes the event schemas used in the ForeTale application event-driven architecture.

## Common Event Format

All events follow the AWS EventBridge schema format:

```json
{
  "version": "0",
  "id": "example-event-id",
  "detail-type": "Event Type",
  "source": "com.foretale.application",
  "account": "AWS_ACCOUNT_ID",
  "time": "2023-01-01T12:00:00Z",
  "region": "eu-west-2",
  "resources": [],
  "detail": {
    // Event-specific data
  }
}
```

## Event Types

### User Events
- `User.Created`
- `User.Updated`
- `User.Deleted`

### Project Events
- `Project.Created`
- `Project.Updated`
- `Project.Deleted`
- `Project.Executed`

### Data Quality Events
- `DataQuality.Analysis.Started`
- `DataQuality.Analysis.Completed`
- `DataQuality.Analysis.Failed`

### Report Events
- `Report.Generated`
- `Report.Shared`
- `Report.Downloaded`

### AI Assistant Events
- `AI.Query.Submitted`
- `AI.Response.Generated`
- `AI.Response.Rated`

## Example Event Payloads

### User Created Event
```json
{
  "version": "0",
  "id": "12345678-1234-1234-1234-123456789012",
  "detail-type": "User.Created",
  "source": "com.foretale.application",
  "account": "442426872653",
  "time": "2023-01-01T12:00:00Z",
  "region": "eu-west-2",
  "resources": [],
  "detail": {
    "userId": "user123",
    "email": "user@example.com",
    "name": "John Doe",
    "timestamp": "2023-01-01T12:00:00Z"
  }
}
```

### Project Executed Event
```json
{
  "version": "0",
  "id": "87654321-4321-4321-4321-210987654321",
  "detail-type": "Project.Executed",
  "source": "com.foretale.application",
  "account": "442426872653",
  "time": "2023-01-01T12:05:00Z",
  "region": "eu-west-2",
  "resources": [],
  "detail": {
    "projectId": "project123",
    "userId": "user123",
    "executionId": "exec456",
    "status": "completed",
    "results": {
      "passedTests": 15,
      "failedTests": 2,
      "totalTests": 17
    },
    "timestamp": "2023-01-01T12:05:00Z"
  }
}
```