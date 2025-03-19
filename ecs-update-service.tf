# Create EventBridge rule to monitor ECR image pushes and what is the name of the Image tag
resource "aws_cloudwatch_event_rule" "ecr_image_push" {
  name        = "${var.project_name}-${var.environment}-${var.event_rule_name}"
  description = "Capture ECR image push events for ${var.repository_name} repository"

  event_pattern = jsonencode({
    source      = ["aws.ecr"]
    detail-type = ["ECR Image Action"]
    detail = {
      action-type = ["PUSH"]
      repository-name = [var.repository_name]
      image-tag    = [var.image_tag]
      result       = ["SUCCESS"]
    }
  })

  tags = var.default_tags
}

# First create an empty zip file to prevent Terraform planning errors
resource "null_resource" "create_empty_zip" {
  provisioner "local-exec" {
    command = "New-Item -Path lambda -ItemType Directory -Force; New-Item -Path lambda/update-ecs-service.zip -ItemType File -Force"
    interpreter = ["PowerShell", "-Command"]
  }
}

# Lambda function to update ECS service
resource "aws_lambda_function" "update_ecs_service" {
  depends_on      = [null_resource.build_lambda]
  function_name    = "${var.project_name}-${var.environment}-${var.lambda_function_name}"
  role             = aws_iam_role.lambda_execution.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.11"
  filename         = "${path.module}/lambda/update-ecs-service.zip"
  source_code_hash = timestamp() # Use timestamp to force update
  timeout          = 30
  memory_size      = 128

  environment {
    variables = {
      ECS_CLUSTER = aws_ecs_cluster.main.name
      ECS_SERVICE = aws_ecs_service.main.name
    }
  }

  tags = var.default_tags
}

# Create Lambda source code using Python instead of Go
resource "null_resource" "lambda_code" {
  depends_on = [null_resource.create_empty_zip]
  
  provisioner "local-exec" {
    command = <<EOT
      New-Item -Path lambda -ItemType Directory -Force
      Set-Content -Path lambda/index.py -Value @'
import boto3
import os
import json

def lambda_handler(event, context):
    try:
        ecs = boto3.client('ecs')
        
        # Get environment variables
        cluster = os.environ['ECS_CLUSTER']
        service = os.environ['ECS_SERVICE']
        
        # Print event details for debugging
        print(f"Event details: {json.dumps(event)}")
        print(f"Updating ECS service {service} in cluster {cluster}")
        
        # Update the service to force new deployment
        response = ecs.update_service(
            cluster=cluster,
            service=service,
            forceNewDeployment=True
        )
        
        print(f"Successfully initiated deployment for service {service}")
        return {
            'statusCode': 200,
            'body': json.dumps('Service update initiated successfully')
        }
        
    except Exception as e:
        print(f"Error updating service: {str(e)}")
        raise e
'@
    EOT
    interpreter = ["PowerShell", "-Command"]
  }

  # Force this to run every time by using a timestamp
  triggers = {
    always_run = "${timestamp()}"
  }
}

# Package Lambda function without requiring Go
resource "null_resource" "build_lambda" {
  depends_on = [null_resource.lambda_code]
  
  provisioner "local-exec" {
    command = <<EOT
      # Compress-Archive can overwrite existing files with -Force
      Compress-Archive -Path lambda/index.py -DestinationPath lambda/update-ecs-service.zip -Force
    EOT
    interpreter = ["PowerShell", "-Command"]
  }
  
  # Force this to run every time by using a timestamp
  triggers = {
    always_run = "${timestamp()}"
  }
}

# Permission for EventBridge to invoke Lambda
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_ecs_service.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ecr_image_push.arn
}

# EventBridge target to trigger Lambda
resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.ecr_image_push.name
  target_id = "TriggerLambda"
  arn       = aws_lambda_function.update_ecs_service.arn
}

# Enhanced IAM policy for Lambda to update ECS service
resource "aws_iam_role_policy" "lambda_ecs_enhanced_policy" {
  name = "${var.project_name}-${var.environment}-${var.lambda_ecs_policy_name}-enhanced"
  role = aws_iam_role.lambda_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:DescribeClusters",
          "ecs:DescribeTaskDefinition",
          "ecr:DescribeImages",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
        Resource = "*"
      }
    ]
  })
}