# Infrastructure Variables
variable "aws_region" {
  description = "AWS region where the resources will be created"
  type        = string
  default     = "ap-southeast-2"
}

# ECR Repository Variables
variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "my-api"
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "The encryption type to use for the repository"
  type        = string
  default     = "AES256"
}

variable "max_image_count" {
  description = "Maximum number of images to keep in the repository"
  type        = number
  default     = 3
}

# General Configuration
variable "environment" {
  description = "Environment (e.g., production, staging, development)"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "CloudStruct"
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default = {
    Name        = "DevOps-NZ"
    Environment = "production"
    Project     = "CloudStruct"
    Managed_by  = "terraform"
  }
}

# Container Configuration
variable "container_cpu" {
  description = "CPU units for the container (1024 = 1 vCPU)"
  type        = number
  default     = 256 # 0.25 vCPU
}

variable "container_memory" {
  description = "Memory for the container in MiB"
  type        = number
  default     = 512 # 0.5GB RAM
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 80
}

# ECS Cluster Configuration
variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "CloudStruct"
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights for the cluster"
  type        = bool
  default     = true
}


# Domain Configuration
variable "domain_name" {
  description = "The primary domain name"
  type        = string
  default     = "artisantiling.co.nz"
}

variable "create_wildcard_certificate" {
  description = "Whether to create a wildcard certificate"
  type        = bool
  default     = true
}

# Aurora MySQL Database Configuration
variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "VPC ID (optional, if not provided the VPC created by this configuration will be used)"
  type        = string
  default     = ""  
}

# Application Load Balancer
variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
  default     = "main-alb"
}

variable "alb_internal" {
  description = "Whether the ALB is internal or internet-facing"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the ALB"
  type        = bool
  default     = false
}

variable "enable_http2" {
  description = "Enable HTTP/2 for the ALB"
  type        = bool
  default     = true
}

variable "target_group_name" {
  description = "Name of the target group"
  type        = string
  default     = "app-tg"
}

variable "target_group_port" {
  description = "Port on which targets receive traffic"
  type        = number
  default     = 80
}

variable "target_group_protocol" {
  description = "Protocol to use for routing traffic to the targets"
  type        = string
  default     = "HTTP"
}

variable "target_type" {
  description = "Type of target that you must specify when registering targets with this target group"
  type        = string
  default     = "ip"
}

variable "deregistration_delay" {
  description = "Amount of time for Elastic Load Balancing to wait before deregistering a target"
  type        = number
  default     = 30
}

variable "slow_start" {
  description = "Amount of time for targets to warm up before the load balancer sends them a full share of requests"
  type        = number
  default     = 60
}

variable "health_check" {
  description = "Health check configuration for the target group"
  type        = map(any)
  default     = {
    enabled             = true
    healthy_threshold   = 2
    interval            = 15
    matcher             = "200"
    path                = "/api/health" //change this depending on your preferred web application endpoints
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
}

variable "stickiness" {
  description = "Stickiness configuration for the target group"
  type        = map(any)
  default     = {
    type            = "app_cookie"
    cookie_name     = "CloudStruct_session"
    cookie_duration = 86400
    enabled         = true
  }
}

variable "http_port" {
  description = "Port for HTTP traffic"
  type        = number
  default     = 80
}

variable "https_port" {
  description = "Port for HTTPS traffic"
  type        = number
  default     = 443
}

variable "ssl_policy" {
  description = "SSL policy for HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

# ECS Cluster
variable "capacity_providers" {
  description = "List of capacity providers to use in the cluster"
  type        = list(string)
  default     = ["FARGATE", "FARGATE_SPOT"]
}

variable "default_capacity_provider" {
  description = "Default capacity provider to use"
  type        = string
  default     = "FARGATE"
}

variable "capacity_provider_base" {
  description = "Base value for the default capacity provider"
  type        = number
  default     = 1
}

variable "capacity_provider_weight" {
  description = "Weight value for the default capacity provider"
  type        = number
  default     = 1
}


# ECS Service Capacity Provider
variable "service_name" {
  description = "Name of the ECS service"
  type        = string
  default     = "main-service"
}

variable "desired_count" {
  description = "Desired number of tasks for the service"
  type        = number
  default     = 2
}

variable "platform_version" {
  description = "Platform version for the Fargate tasks"
  type        = string
  default     = "LATEST"
}

variable "force_new_deployment" {
  description = "Force a new deployment of the service"
  type        = bool
  default     = true
}

variable "enable_circuit_breaker" {
  description = "Enable deployment circuit breaker"
  type        = bool
  default     = true
}

variable "enable_rollback" {
  description = "Enable rollback on deployment failure"
  type        = bool
  default     = true
}

variable "deployment_controller_type" {
  description = "Type of deployment controller"
  type        = string
  default     = "ECS"
}

variable "fargate_base" {
  description = "Base value for Fargate capacity provider"
  type        = number
  default     = 2
}

variable "fargate_weight" {
  description = "Weight value for Fargate capacity provider"
  type        = number
  default     = 1
}

variable "fargate_spot_base" {
  description = "Base value for Fargate Spot capacity provider"
  type        = number
  default     = 0
}

variable "fargate_spot_weight" {
  description = "Weight value for Fargate Spot capacity provider"
  type        = number
  default     = 3
}

variable "max_capacity" {
  description = "Maximum number of tasks for auto scaling"
  type        = number
  default     = 20
}

variable "min_capacity" {
  description = "Minimum number of tasks for auto scaling"
  type        = number
  default     = 2
}

variable "cpu_target_value" {
  description = "Target CPU utilization percentage for auto scaling"
  type        = number
  default     = 70
}

variable "memory_target_value" {
  description = "Target memory utilization percentage for auto scaling"
  type        = number
  default     = 80
}

variable "request_count_target" {
  description = "Target request count per target for auto scaling"
  type        = number
  default     = 1000
}

variable "scale_in_cooldown" {
  description = "Scale in cooldown period in seconds"
  type        = number
  default     = 300
}

variable "scale_out_cooldown" {
  description = "Scale out cooldown period in seconds"
  type        = number
  default     = 60
}

# ECS Automation Update Service
variable "event_rule_name" {
  description = "Name of the EventBridge rule for ECR image pushes"
  type        = string
  default     = "ecr-image-push-rule"
}

variable "eventbridge_lambda_role_name" {
  description = "Name of the IAM role for EventBridge to invoke Lambda"
  type        = string
  default     = "eventbridge-lambda-role"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function to update ECS service"
  type        = string
  default     = "update-ecs-service"
}

variable "lambda_execution_role_name" {
  description = "Name of the IAM role for Lambda execution"
  type        = string
  default     = "lambda-execution-role"
}

variable "lambda_ecs_policy_name" {
  description = "Name of the IAM policy for Lambda to update ECS service"
  type        = string
  default     = "lambda-ecs-policy"
}

variable "lambda_handler" {
  description = "Handler for the Lambda function"
  type        = string
  default     = "bootstrap"
}

variable "lambda_runtime" {
  description = "Runtime for the Lambda function"
  type        = string
  default     = "provided.al2023"
}

variable "lambda_zip_path" {
  description = "Path to the Lambda function zip file"
  type        = string
  default     = "lambda/update-ecs-service.zip"
}

variable "image_tag" {
  description = "Docker image tag as well as use to monitor the name of the tag for ECR pushes"
  type        = string
  default     = "jellybean"
}

# IAM policy and Roles
variable "ecs_execution_role_name" {
  description = "Name of the IAM role for ECS task execution"
  type        = string
  default     = "ecs-execution-role"
}

variable "ecs_task_role_name" {
  description = "Name of the IAM role for ECS tasks"
  type        = string
  default     = "ecs-task-role"
}

variable "ecs_task_role_policy_name" {
  description = "Name of the IAM policy for ECS task role"
  type        = string
  default     = "ecs-task-role-policy"
}

# ECS Task Definitions
variable "task_family" {
  description = "Family name of the task definition"
  type        = string
  default     = "api-task"
}

variable "requires_compatibilities" {
  description = "Launch types required by the task"
  type        = list(string)
  default     = ["EC2", "FARGATE"]
}

variable "network_mode" {
  description = "Docker networking mode to use for the containers"
  type        = string
  default     = "awsvpc"
}

variable "operating_system_family" {
  description = "Operating system family for the task"
  type        = string
  default     = "LINUX"
}

variable "cpu_architecture" {
  description = "CPU architecture for the task"
  type        = string
  default     = "X86_64"
}

