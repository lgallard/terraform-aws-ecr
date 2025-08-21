# ----------------------------------------------------------
# CloudWatch Monitoring and Alerting
# ----------------------------------------------------------

# Local configuration for SNS resources
locals {
  sns_topics = var.enable_monitoring && var.create_sns_topic ? {
    ecr_monitoring = {
      name         = var.sns_topic_name != null ? var.sns_topic_name : "${var.name}-ecr-monitoring"
      display_name = "ECR Monitoring Alerts for ${var.name}"
      tag_name     = var.sns_topic_name != null ? var.sns_topic_name : "${var.name}-ecr-monitoring"
    }
  } : {}

  # Create subscription mappings for for_each
  sns_subscriptions = var.enable_monitoring && var.create_sns_topic ? {
    for idx, email in var.sns_topic_subscribers : "subscription-${idx}" => {
      topic_key = "ecr_monitoring"
      protocol  = "email"
      endpoint  = email
    }
  } : {}

  # Updated SNS topic ARN local
  sns_topic_arn = var.enable_monitoring ? (
    var.create_sns_topic ? try(aws_sns_topic.ecr_monitoring["ecr_monitoring"].arn, null) :
    (var.sns_topic_name != null ? "arn:aws:sns:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:${var.sns_topic_name}" : null)
  ) : null
}

# SNS Topic for CloudWatch alarm notifications
resource "aws_sns_topic" "ecr_monitoring" {
  for_each = local.sns_topics

  name         = each.value.name
  display_name = each.value.display_name

  tags = merge(
    local.final_tags,
    {
      Name = each.value.tag_name
    }
  )
}

# SNS Topic subscriptions
resource "aws_sns_topic_subscription" "ecr_monitoring_email" {
  for_each = local.sns_subscriptions

  topic_arn = aws_sns_topic.ecr_monitoring[each.value.topic_key].arn
  protocol  = each.value.protocol
  endpoint  = each.value.endpoint
}

# Local configuration for CloudWatch alarms
locals {
  cloudwatch_alarms = var.enable_monitoring ? {
    storage_usage = {
      alarm_name          = "${var.name}-ecr-storage-usage"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = "2"
      metric_name         = "RepositorySizeInBytes"
      namespace           = "AWS/ECR"
      period              = "300"
      statistic           = "Average"
      threshold           = var.monitoring_threshold_storage * 1024 * 1024 * 1024 # Convert GB to bytes
      alarm_description   = "This metric monitors ECR repository storage usage for ${var.name}"
      tag_name            = "${var.name}-ecr-storage-usage-alarm"
      enabled             = true
      dimensions = {
        RepositoryName = local.repository_name
      }
    }
    api_call_volume = {
      alarm_name          = "${var.name}-ecr-api-calls"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = "2"
      metric_name         = "ApiCallCount"
      namespace           = "AWS/ECR"
      period              = "60"
      statistic           = "Sum"
      threshold           = var.monitoring_threshold_api_calls
      alarm_description   = "This metric monitors ECR API call volume for ${var.name}"
      tag_name            = "${var.name}-ecr-api-calls-alarm"
      enabled             = true
      dimensions = {
        RepositoryName = local.repository_name
      }
    }
    image_push_count = {
      alarm_name          = "${var.name}-ecr-image-push"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = "2"
      metric_name         = "ImagePushCount"
      namespace           = "AWS/ECR"
      period              = "300"
      statistic           = "Sum"
      threshold           = var.monitoring_threshold_image_push
      alarm_description   = "This metric monitors ECR image push frequency for ${var.name}"
      tag_name            = "${var.name}-ecr-image-push-alarm"
      enabled             = true
      dimensions = {
        RepositoryName = local.repository_name
      }
    }
    image_pull_count = {
      alarm_name          = "${var.name}-ecr-image-pull"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = "2"
      metric_name         = "ImagePullCount"
      namespace           = "AWS/ECR"
      period              = "300"
      statistic           = "Sum"
      threshold           = var.monitoring_threshold_image_pull
      alarm_description   = "This metric monitors ECR image pull frequency for ${var.name}"
      tag_name            = "${var.name}-ecr-image-pull-alarm"
      enabled             = true
      dimensions = {
        RepositoryName = local.repository_name
      }
    }
    security_findings = {
      alarm_name          = "${var.name}-ecr-security-findings"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = "1"
      metric_name         = "HighSeverityVulnerabilityCount"
      namespace           = "AWS/ECR"
      period              = "300"
      statistic           = "Maximum"
      threshold           = var.monitoring_threshold_security_findings
      alarm_description   = "This metric monitors ECR security findings for ${var.name}"
      tag_name            = "${var.name}-ecr-security-findings-alarm"
      enabled             = var.enable_registry_scanning
      dimensions = {
        RepositoryName = local.repository_name
      }
    }
  } : {}
}

# CloudWatch Alarms using for_each pattern
resource "aws_cloudwatch_metric_alarm" "monitoring" {
  for_each = { for k, v in local.cloudwatch_alarms : k => v if v.enabled }

  alarm_name          = each.value.alarm_name
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  alarm_description   = each.value.alarm_description
  alarm_actions       = local.sns_topic_arn != null ? [local.sns_topic_arn] : []
  ok_actions          = local.sns_topic_arn != null ? [local.sns_topic_arn] : []

  dimensions = each.value.dimensions

  tags = merge(
    local.final_tags,
    {
      Name = each.value.tag_name
    }
  )

  depends_on = [
    aws_ecr_repository.repo,
    aws_ecr_repository.repo_protected
  ]
}





# ----------------------------------------------------------
# Pull Request Rules Event Handling
# ----------------------------------------------------------

# Local values for pull request rules event handling
locals {
  # Generate CloudWatch Event Rules for pull request rules
  pull_request_rule_events = local.pull_request_rules_enabled ? [
    for rule in local.enabled_pull_request_rules : {
      name = rule.name
      type = rule.type
      event_pattern = jsonencode({
        source      = ["aws.ecr"]
        detail-type = ["ECR Image Action"]
        detail = {
          action-type     = ["PUSH"]
          repository-name = [local.repository_name]
        }
      })
      notification_topic_arn = try(rule.actions.notification_topic_arn, null)
      webhook_url            = try(rule.actions.webhook_url, null)
    } if try(rule.actions.notification_topic_arn, null) != null || try(rule.actions.webhook_url, null) != null
  ] : []

  # Filtered events for SNS notifications with original indices
  pull_request_rule_events_sns = local.pull_request_rules_enabled ? [
    for i, event in local.pull_request_rule_events : {
      event          = event
      original_index = i
    }
    if event.notification_topic_arn != null
  ] : []

  # Filtered events for webhook notifications with original indices
  pull_request_rule_events_webhook = local.pull_request_rules_enabled ? [
    for i, event in local.pull_request_rule_events : {
      event          = event
      original_index = i
    }
    if event.webhook_url != null
  ] : []
}

# SNS Topic for pull request rule notifications (if not provided)
resource "aws_sns_topic" "pull_request_rules" {
  count = local.pull_request_rules_enabled && length([
    for rule in local.enabled_pull_request_rules : rule
    if try(rule.actions.notification_topic_arn, null) == null && try(rule.actions.webhook_url, null) == null
  ]) > 0 ? 1 : 0

  name = "${var.name}-ecr-pull-request-rules"

  tags = merge(
    local.final_tags,
    {
      Name = "${var.name}-ecr-pull-request-rules"
      Type = "PullRequestRules"
    }
  )
}

# CloudWatch Event Rule for pull request rules
resource "aws_cloudwatch_event_rule" "pull_request_rules" {
  for_each = { for i, event in local.pull_request_rule_events : "${i}-${event.name}" => event }

  name        = "${var.name}-ecr-pr-rule-${each.value.name}"
  description = "Pull request rule event for ${each.value.name}"

  event_pattern = each.value.event_pattern

  tags = merge(
    local.final_tags,
    {
      Name     = "${var.name}-ecr-pr-rule-${each.value.name}"
      Type     = "PullRequestRule"
      RuleType = each.value.type
    }
  )
}

# CloudWatch Event Target for SNS notifications
resource "aws_cloudwatch_event_target" "pull_request_rules_sns" {
  for_each = { for i, item in local.pull_request_rule_events_sns : "sns-${i}" => item }

  rule      = aws_cloudwatch_event_rule.pull_request_rules["${each.value.original_index}-${each.value.event.name}"].name
  target_id = "SendToSNS"
  arn       = each.value.event.notification_topic_arn

  input_transformer {
    input_paths = {
      repository = "$.detail.repository-name"
      tag        = "$.detail.image-tag"
      action     = "$.detail.action-type"
      time       = "$.time"
    }
    input_template = jsonencode({
      repository = "<repository>"
      tag        = "<tag>"
      action     = "<action>"
      time       = "<time>"
      message    = "ECR pull request rule triggered for repository <repository>, tag <tag>"
    })
  }
}

# CloudWatch Event Target for webhook notifications
resource "aws_cloudwatch_event_target" "pull_request_rules_webhook" {
  for_each = { for i, item in local.pull_request_rule_events_webhook : "webhook-${i}" => item }

  rule      = aws_cloudwatch_event_rule.pull_request_rules["${each.value.original_index}-${each.value.event.name}"].name
  target_id = "SendToWebhook"
  arn       = aws_lambda_function.pull_request_rules_webhook[each.key].arn

  input_transformer {
    input_paths = {
      repository = "$.detail.repository-name"
      tag        = "$.detail.image-tag"
      action     = "$.detail.action-type"
      time       = "$.time"
    }
    input_template = jsonencode({
      repository  = "<repository>"
      tag         = "<tag>"
      action      = "<action>"
      time        = "<time>"
      webhook_url = each.value.event.webhook_url
    })
  }
}

# Lambda function for webhook notifications
resource "aws_lambda_function" "pull_request_rules_webhook" {
  for_each = { for i, item in local.pull_request_rule_events_webhook : "webhook-${i}" => item }

  filename      = data.archive_file.pull_request_rules_webhook[each.key].output_path
  function_name = "${var.name}-ecr-pr-webhook-${each.value.event.name}"
  role          = aws_iam_role.pull_request_rules_webhook[each.key].arn
  handler       = "index.handler"
  runtime       = "python3.12"
  timeout       = 30

  environment {
    variables = {
      WEBHOOK_URL = each.value.event.webhook_url
    }
  }

  tags = merge(
    local.final_tags,
    {
      Name = "${var.name}-ecr-pr-webhook-${each.value.event.name}"
      Type = "PullRequestRuleWebhook"
    }
  )
}

# Lambda function code for webhook notifications
data "archive_file" "pull_request_rules_webhook" {
  for_each = { for i, item in local.pull_request_rule_events_webhook : "webhook-${i}" => item }

  type        = "zip"
  output_path = "/tmp/pull_request_rules_webhook_${each.value.event.name}.zip"

  source {
    content  = <<-EOF
import json
import urllib3
import os

def handler(event, context):
    webhook_url = os.environ['WEBHOOK_URL']

    # Extract event details
    detail = event.get('detail', {})
    repository = detail.get('repository-name', '')
    tag = detail.get('image-tag', '')
    action = detail.get('action-type', '')

    # Create webhook payload
    payload = {
        'repository': repository,
        'tag': tag,
        'action': action,
        'time': event.get('time', ''),
        'message': f'ECR pull request rule triggered for repository {repository}, tag {tag}'
    }

    # Send webhook
    http = urllib3.PoolManager()
    response = http.request(
        'POST',
        webhook_url,
        body=json.dumps(payload),
        headers={'Content-Type': 'application/json'}
    )

    return {
        'statusCode': 200,
        'body': json.dumps('Webhook sent successfully')
    }
EOF
    filename = "index.py"
  }
}

# IAM role for Lambda webhook function
resource "aws_iam_role" "pull_request_rules_webhook" {
  for_each = { for i, item in local.pull_request_rule_events_webhook : "webhook-${i}" => item }

  name = "${var.name}-ecr-pr-webhook-role-${each.value.event.name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    local.final_tags,
    {
      Name = "${var.name}-ecr-pr-webhook-role-${each.value.event.name}"
      Type = "PullRequestRuleWebhookRole"
    }
  )
}

# IAM policy attachment for Lambda webhook function
resource "aws_iam_role_policy_attachment" "pull_request_rules_webhook" {
  for_each = { for i, item in local.pull_request_rule_events_webhook : "webhook-${i}" => item }

  role       = aws_iam_role.pull_request_rules_webhook[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda permission for CloudWatch Events
resource "aws_lambda_permission" "pull_request_rules_webhook" {
  for_each = { for i, item in local.pull_request_rule_events_webhook : "webhook-${i}" => item }

  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pull_request_rules_webhook[each.key].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.pull_request_rules["${each.value.original_index}-${each.value.event.name}"].arn
}
