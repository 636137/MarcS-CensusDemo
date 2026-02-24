# Census Enumerator AI Agent - Outputs

output "lex_bot_id" {
  description = "Amazon Lex bot ID"
  value       = module.lex.bot_id
}

output "lex_bot_arn" {
  description = "Amazon Lex bot ARN"
  value       = module.lex.bot_arn
}

output "lex_bot_alias_id" {
  description = "Amazon Lex bot alias ID"
  value       = module.lex.bot_alias_id
}

output "lex_bot_alias_arn" {
  description = "Amazon Lex bot alias ARN"
  value       = module.lex.bot_alias_arn
}

output "lambda_fulfillment_arn" {
  description = "Lambda fulfillment function ARN"
  value       = module.lambda.fulfillment_lambda_arn
}

output "lambda_backend_arn" {
  description = "Lambda backend function ARN"
  value       = module.lambda.backend_lambda_arn
}

output "dynamodb_census_responses_table" {
  description = "DynamoDB Census Responses table name"
  value       = module.dynamodb.census_responses_table_name
}

output "dynamodb_census_addresses_table" {
  description = "DynamoDB Census Addresses table name"
  value       = module.dynamodb.census_addresses_table_name
}

output "bedrock_guardrail_id" {
  description = "Bedrock guardrail ID"
  value       = module.bedrock.guardrail_id
}

output "bedrock_guardrail_arn" {
  description = "Bedrock guardrail ARN"
  value       = module.bedrock.guardrail_arn
}

output "cloudwatch_dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = module.monitoring.dashboard_url
}

output "lambda_execution_role_arn" {
  description = "Lambda execution role ARN"
  value       = module.iam.lambda_execution_role_arn
}

output "deployment_region" {
  description = "AWS region where resources are deployed"
  value       = var.aws_region
}

output "environment" {
  description = "Deployment environment"
  value       = var.environment
}

# Amazon Connect integration outputs (when using existing instance)
output "connect_integration_instructions" {
  description = "Instructions for integrating with Amazon Connect"
  value       = <<-EOT
    To integrate with Amazon Connect:
    
    1. Associate the Lex bot with your Connect instance:
       aws connect associate-lex-bot \
         --instance-id ${var.connect_instance_id != "" ? var.connect_instance_id : "<YOUR_CONNECT_INSTANCE_ID>"} \
         --lex-bot Name=${module.lex.bot_name},LexRegion=${var.aws_region}
    
    2. Import the contact flow:
       Use the contact-flow.json file and update with:
       - Lex Bot ARN: ${module.lex.bot_alias_arn}
       - Lambda ARN: ${module.lambda.backend_lambda_arn}
    
    3. Associate a phone number with the contact flow
    
    4. Configure chat widget with your instance ID
  EOT
}
