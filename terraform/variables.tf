# Census Enumerator AI Agent - Variables

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod"
  }
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "census-enumerator"
}

variable "owner" {
  description = "Owner tag for resources"
  type        = string
  default     = "census-bureau"
}

# Bedrock Configuration
variable "bedrock_model_id" {
  description = "Amazon Bedrock model ID for AI agent"
  type        = string
  default     = "anthropic.claude-3-sonnet-20240229-v1:0"
}

# Lex Configuration
variable "lex_voice_id" {
  description = "Amazon Polly voice ID for Lex bot"
  type        = string
  default     = "Ruth"
}

variable "lex_locale" {
  description = "Locale for Lex bot"
  type        = string
  default     = "en_US"
}

variable "lex_nlu_confidence_threshold" {
  description = "NLU confidence threshold for intent matching"
  type        = number
  default     = 0.40
}

# Lambda Configuration
variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "nodejs18.x"
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Lambda memory size in MB"
  type        = number
  default     = 256
}

# DynamoDB Configuration
variable "dynamodb_billing_mode" {
  description = "DynamoDB billing mode (PAY_PER_REQUEST or PROVISIONED)"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "dynamodb_enable_encryption" {
  description = "Enable server-side encryption for DynamoDB tables"
  type        = bool
  default     = true
}

variable "dynamodb_enable_point_in_time_recovery" {
  description = "Enable point-in-time recovery for DynamoDB tables"
  type        = bool
  default     = true
}

# Amazon Connect Configuration
variable "create_connect_instance" {
  description = "Whether to create a new Amazon Connect instance (set to false to use existing)"
  type        = bool
  default     = true
}

variable "connect_instance_id" {
  description = "Existing Amazon Connect instance ID (required if create_connect_instance is false)"
  type        = string
  default     = ""
}

variable "connect_instance_alias" {
  description = "Unique alias for the Amazon Connect instance (lowercase, alphanumeric, hyphens only)"
  type        = string
  default     = "census-enumerator"
  
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.connect_instance_alias))
    error_message = "Instance alias must be lowercase alphanumeric with hyphens, cannot start/end with hyphen."
  }
}

variable "connect_contact_flow_name" {
  description = "Name for the Census Enumerator contact flow"
  type        = string
  default     = "CensusEnumeratorFlow"
}

# Connect Users Configuration
variable "agent_emails" {
  description = "List of email addresses for test agent users"
  type        = list(string)
  default     = [
    "census.agent1@example.com",
    "census.agent2@example.com",
    "census.agent3@example.com",
    "census.agent4@example.com",
    "census.agent5@example.com"
  ]
}

variable "supervisor_email" {
  description = "Email address for the supervisor user"
  type        = string
  default     = "census.supervisor@example.com"
}

# Monitoring Configuration
variable "alarm_sns_topic_arn" {
  description = "SNS topic ARN for CloudWatch alarms (optional)"
  type        = string
  default     = ""
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 90
}

# Security Configuration
variable "enable_kms_encryption" {
  description = "Enable KMS encryption for sensitive data"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "Existing KMS key ARN (leave empty to create new key)"
  type        = string
  default     = ""
}

# VPC Configuration (optional)
variable "vpc_id" {
  description = "VPC ID for Lambda deployment (optional)"
  type        = string
  default     = ""
}

variable "vpc_subnet_ids" {
  description = "Subnet IDs for Lambda VPC configuration"
  type        = list(string)
  default     = []
}

variable "vpc_security_group_ids" {
  description = "Security group IDs for Lambda VPC configuration"
  type        = list(string)
  default     = []
}
