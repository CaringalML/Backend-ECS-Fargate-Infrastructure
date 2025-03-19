# Add this variable to your variables.tf file
variable "log_retention_days" {
  description = "Number of days to retain logs in CloudWatch"
  type        = number
  default     = 30
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "CloudStruct" {
  name              = "/ecs/${var.project_name}-${var.environment}-${var.repository_name}"
  retention_in_days = var.log_retention_days
  
  tags = var.default_tags
}

# CloudWatch Log Group for Cluster
resource "aws_cloudwatch_log_group" "cluster_logs" {
  name              = "/ecs/${var.cluster_name}"
  retention_in_days = var.log_retention_days
  
  tags = var.default_tags
}

# CloudWatch Logs policy for Lambda
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}