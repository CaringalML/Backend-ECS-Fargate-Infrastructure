# CloudStruct: Enterprise Serverless Architecture with AWS Fargate, Lambda, Aurora, and CI/CD Pipeline

This repository contains Terraform Infrastructure as Code (IaC) for a production-grade serverless application platform deployed on AWS. The architecture leverages cutting-edge cloud services including ECS Fargate, Lambda functions, Aurora Serverless v2, and EventBridge to create a fully managed, auto-scaling infrastructure with zero server maintenance.

## The Journey: From Development to Production

### The Challenge

Building a production-ready serverless infrastructure presented several challenges. As a sole developer, I faced the complexity of designing a system that offered both scalability and minimal maintenance. Traditional server-based deployments might have been simpler, but I wanted to create something more advanced - a fully automated, highly available system that could scale with demand while eliminating operational overhead.

### The Solution Story

My infrastructure journey began with designing a multi-AZ architecture to ensure high availability. I separated the application into distinct layers - public-facing load balancers in public subnets and containerized applications running in private subnets for security. I placed the Aurora Serverless database in isolated private subnets with access only from application containers.

One of the early challenges I faced was configuring the ALB health check path correctly. Setting it to `/api/health` seemed logical, but my initial deployments failed because:

1. The application hadn't implemented this endpoint yet
2. The health check was timing out before the application could initialize

I had to temporarily adjust the health check settings to be more lenient during initial deployment, then tighten them once the application was stable. **Important note for anyone deploying this infrastructure**: ensure your application has a working health check endpoint before deployment, or modify the `health_check` variable in `variables.tf` to match your application's actual health check path.

Another significant challenge I overcame was the "chicken and egg" problem with ECS services and ECR images. My ECS service needed an image to deploy, but the ECR repository was being created by the same Terraform code. I solved this with a two-phase approach:

1. First deployment: Create infrastructure including ECR repository
2. Immediately push an initial container image using GitHub Actions
3. Second deployment: Complete ECS service creation with the available image

Without an image in ECR, the ECS service deployment would fail with "Unable to find image" errors. **Critical step**: After creating the ECR repository, you must immediately run the GitHub Actions workflow to push an initial image before the ECS service can deploy successfully.

The EventBridge + Lambda automation for continuous deployment also required careful IAM permission configuration. My initial deployments failed because the Lambda function lacked permissions to update the ECS service. I enhanced the policy to include all necessary ECS and ECR permissions, creating a fully automated pipeline that triggers deployments whenever a new image is pushed.

A particularly elegant solution I implemented was the automated Lambda function code packaging. Instead of requiring manual ZIP file creation, I used Terraform's `null_resource` with local-exec provisioners to automatically:

1. Create the Python Lambda code (`index.py`)
2. Package it into a ZIP file during the `terraform apply` process
3. Update the Lambda function with the fresh code

This automation means anyone deploying the infrastructure doesn't need to manually create or manage the Lambda deployment package - it's all handled by Terraform.

### The Result

The result is a resilient, scalable, and fully automated serverless infrastructure that requires minimal maintenance. The system automatically scales up during high traffic and scales down during quiet periods, optimizing cost without sacrificing performance. I'm particularly proud of the CI/CD pipeline that ensures new code deployments are seamless and require no manual intervention.

## Architecture Overview

This infrastructure implements a modern, scalable, and highly available architecture with the following components:

- VPC with public and private subnets across two availability zones
- ECS Fargate for container orchestration
- Aurora MySQL Serverless v2 for database
- Application Load Balancer for traffic distribution
- ACM for SSL/TLS certificate management
- Route 53 for DNS management
- ECR for container image storage
- Auto-scaling based on CPU, memory, and request count
- Automated deployment pipeline via EventBridge and Lambda

![Architecture Diagram](AWS-ECS-Fargate.png)

## Infrastructure Components

## Deployment

### Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform 1.0.0+
- Docker (for building container images)
- A registered domain in Route 53
- GitHub repository with GitHub Actions configured

### Deployment Steps

1. Clone this repository
2. Configure the following GitHub Actions secrets:
   - `AWS_ACCESS_KEY_ID`: Your AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key
   - `AWS_REGION`: Your AWS region (e.g., ap-southeast-2)
   - `DB_SERVER`: Database server endpoint (Aurora endpoint)
   - `DB_NAME`: Database name
   - `DB_USER`: Database username
   - `DB_PASSWORD`: Database password
   - `ECR_REPOSITORY`: ECR repository name
3. **Create your own terraform.tfvars file** (this file is in .gitignore):
   ```
   # Required database variables
   db_name     = "yourdbname"
   db_username = "yourusername"
   db_password = "yourpassword"
   
   # Optional variables you may want to customize
   aws_region = "your-preferred-region"
   domain_name = "your-domain.com"
   project_name = "YourProjectName" 
   
   # Add any other variables you want to override
   ```
4. Update other configuration parameters in your terraform.tfvars as needed
5. Push changes to the main branch to trigger the GitHub Actions workflow

## Configuration Variables

Key configuration variables can be customized in `terraform.tfvars` and `variables.tf`:

- `project_name`: Base name for resources (default: "CloudStruct")
- `environment`: Environment name (default: "production")
- `domain_name`: Primary domain name (default: "artisantiling.co.nz")
- `db_name`, `db_username`, `db_password`: Database credentials

## Infrastructure Components

### Networking (vpc.tf)

- **VPC**: Class C IP address space (192.168.0.0/24)
- **Subnets**: 
  - 2 public subnets for ALB (192.168.0.0/26, 192.168.0.64/26)
  - 2 private subnets for ECS tasks and database (192.168.0.128/26, 192.168.0.192/26)
- **NAT Gateways**: One per AZ for outbound internet access from private subnets
- **Internet Gateway**: For public subnet internet access
- **S3 VPC Endpoint**: For secure access to S3 without traversing the internet

Documentation: [AWS VPC](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html)

### Container Registry (ecr.tf)

- Amazon ECR repository for storing container images
- Image scanning on push for security vulnerability detection
- Lifecycle policy to limit repository to the latest 3 images

Documentation: [Amazon ECR](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html)

### Container Orchestration (cluster.tf, task-definition.tf, ecs-fargate-service.tf)

- ECS cluster with FARGATE and FARGATE_SPOT capacity providers
- Task definition with resource allocation (256 CPU units, 512MB memory)
- Service configuration with capacity provider strategy
- Auto-scaling policies based on:
  - CPU utilization (70%)
  - Memory utilization (80%)
  - Request count per target (1000)

Documentation: 
- [Amazon ECS](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html)
- [AWS Fargate](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html)

### Load Balancing (alb.tf)

- Application Load Balancer for traffic distribution
- Target group with health checks at `/api/health`
- HTTP to HTTPS redirect
- Sticky sessions for maintaining user state

Documentation: [Elastic Load Balancing](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)

### Database (aurora-mysql.tf)

- Aurora MySQL Serverless v2 cluster
- Multi-AZ deployment with 2 instances
- Autoscaling from 0.5 to 4 ACUs (Aurora Capacity Units)
- 7-day backup retention

Documentation: [Amazon Aurora](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/CHAP_AuroraOverview.html)

### Security (security-group.tf, iam.tf)

- Security groups with least privilege access:
  - ALB: Accept HTTP/HTTPS from internet
  - Fargate: Accept traffic only from ALB
  - Database: Accept traffic only from Fargate tasks
- IAM roles for:
  - ECS task execution
  - ECS task (application permissions)
  - Lambda execution

Documentation:
- [Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html)
- [IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html)

### SSL/TLS and DNS (acm.tf, route53-dns-record.tf)

- ACM certificate for domain with DNS validation
- Route 53 A record for `server.example.com` pointing to ALB
- Optional wildcard certificate for subdomains

Documentation:
- [AWS Certificate Manager](https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html)
- [Amazon Route 53](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/Welcome.html)

### Monitoring and Logging (cloudwatch.tf)

- CloudWatch Log Groups for ECS services with 30-day retention
- Container Insights enabled for enhanced monitoring

Documentation: [Amazon CloudWatch](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/WhatIsCloudWatch.html)

### Continuous Deployment (ecs-update-service.tf)

- EventBridge rule to monitor ECR image pushes with tag "jellybean"
- Lambda function to trigger ECS service updates automatically
- **Python Lambda Packaging**: Automatic code generation and ZIP packaging during `terraform apply`
- PowerShell scripts handle the packaging process with no manual intervention needed

Documentation:
- [Amazon EventBridge](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-what-is.html)
- [AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html)

### CI/CD Workflow

This project includes a GitHub Actions workflow for continuous integration and deployment. The workflow file (`.github/workflows/build-deploy.yml`) automatically:

1. Builds the application container image
2. Creates an `appsettings.json` with database connection strings using GitHub secrets 
3. Pushes the image to Amazon ECR with the tag "jellybean"
4. Triggers automatic deployment via the EventBridge and Lambda function

```yaml
name: Build and Deploy to AWS ECR

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
      
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ secrets.AWS_REGION }}
      
    - name: Login to Amazon ECR
      id: login-ecr
      uses: aws-actions/amazon-ecr-login@v1
      
    - name: Create appsettings.json
      run: |
        cat > appsettings.json << EOF
        {
          "ConnectionStrings": {
            "DefaultConnection": "Server=${{ secrets.DB_SERVER }};Database=${{ secrets.DB_NAME }};User=${{ secrets.DB_USER }};Password=${{ secrets.DB_PASSWORD }};"
          },
          "Logging": {
            "LogLevel": {
              "Default": "Information",
              "Microsoft.AspNetCore": "Warning"
            }
          },
          "AllowedHosts": "*"
        }
        EOF
        
    - name: Build and push image to AWS ECR
      env:
        ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
        ECR_REPOSITORY: ${{ secrets.ECR_REPOSITORY }}
      run: |
        docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:jellybean .
        docker push $ECR_REGISTRY/$ECR_REPOSITORY:jellybean
```

After deployment, monitor the ECS service in the AWS Console.

## Lambda Code Packaging

One of the unique features of this infrastructure is the automatic Python Lambda code packaging during deployment:

```terraform
# First create an empty zip file to prevent Terraform planning errors
resource "null_resource" "create_empty_zip" {
  provisioner "local-exec" {
    command = "New-Item -Path lambda -ItemType Directory -Force; New-Item -Path lambda/update-ecs-service.zip -ItemType File -Force"
    interpreter = ["PowerShell", "-Command"]
  }
}

# Create Lambda source code using Python
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
    # Lambda function code here
'@
    EOT
    interpreter = ["PowerShell", "-Command"]
  }
  
  # Force this to run every time by using a timestamp
  triggers = {
    always_run = "${timestamp()}"
  }
}

# Package Lambda function
resource "null_resource" "build_lambda" {
  depends_on = [null_resource.lambda_code]
  
  provisioner "local-exec" {
    command = <<EOT
      Compress-Archive -Path lambda/index.py -DestinationPath lambda/update-ecs-service.zip -Force
    EOT
    interpreter = ["PowerShell", "-Command"]
  }
  
  # Force this to run every time by using a timestamp
  triggers = {
    always_run = "${timestamp()}"
  }
}
```

This automation removes the need to manually create or maintain the Lambda function code. The PowerShell commands will:

1. Create the necessary directory structure
2. Generate the Python code file with the Lambda function
3. Package it into a ZIP file
4. Update the Lambda function with the fresh package during each `terraform apply`

## Configuration Variables

The infrastructure is highly customizable through variables defined in `variables.tf`. Here are the key variables grouped by category:

### General Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `project_name` | Base name for resources | `"CloudStruct"` |
| `environment` | Environment name | `"production"` |
| `aws_region` | AWS region | `"ap-southeast-2"` |
| `domain_name` | Primary domain name | `"artisantiling.co.nz"` |
| `default_tags` | Default tags for resources | `{ Name = "DevOps-NZ", Environment = "production", ... }` |

### Container and ECS Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `container_cpu` | CPU units for container (1024 = 1 vCPU) | `256` |
| `container_memory` | Memory for container in MiB | `512` |
| `container_port` | Port exposed by container | `80` |
| `cluster_name` | Name of ECS cluster | `"CloudStruct"` |
| `desired_count` | Desired number of ECS tasks | `2` |
| `max_capacity` | Maximum tasks for auto-scaling | `20` |
| `min_capacity` | Minimum tasks for auto-scaling | `2` |
| `image_tag` | Docker image tag to deploy | `"jellybean"` |

### Database Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `db_name` | Database name | Required |
| `db_username` | Database username | Required |
| `db_password` | Database password (sensitive) | Required |

### Auto-Scaling Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `cpu_target_value` | Target CPU utilization % | `70` |
| `memory_target_value` | Target memory utilization % | `80` |
| `request_count_target` | Target request count per target | `1000` |
| `scale_in_cooldown` | Scale in cooldown in seconds | `300` |
| `scale_out_cooldown` | Scale out cooldown in seconds | `60` |

### Health Check Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `health_check` | Health check settings | `{ path = "/api/health", interval = 15, ... }` |

For the complete list of variables, refer to the `variables.tf` file.

## Outputs

The following outputs are available after deployment:

- `repository_url`: ECR repository URL
- `task_definition_arn`: ECS task definition ARN
- `cluster_arn`: ECS cluster ARN
- `cluster_name`: ECS cluster name
- `certificate_arn`: ACM certificate ARN
- `zone_id`: Route 53 zone ID
- `server_dns`: DNS name for the server subdomain
- `rds_endpoint`: Aurora database endpoint
- `rds_reader_endpoint`: Aurora database reader endpoint
- `rds_port`: Aurora database port

## Security Considerations

- The `terraform.tfvars` file is included in `.gitignore` to prevent committing sensitive information
- You must create your own `terraform.tfvars` file locally with database credentials
- Database credentials are securely stored as GitHub Actions secrets and injected during deployment
- Consider enabling deletion protection in production
- Database has `skip_final_snapshot` set to true, which should be changed in production
- For additional security, consider using AWS Secrets Manager for runtime credential access

## Maintenance and Operations

### Scaling

The infrastructure automatically scales based on:
- CPU utilization (target: 70%)
- Memory utilization (target: 80%)
- Request count per target (target: 1000)

You can adjust these values in `variables.tf`.

### Monitoring

Monitor your application using:
- CloudWatch Container Insights
- CloudWatch Logs
- ALB access logs

### Updating the Application

The application updates automatically through the CI/CD pipeline:

1. Make changes to your application code
2. Commit and push to the main branch
3. GitHub Actions will build a new container image with the "jellybean" tag
4. The image is pushed to ECR, triggering the EventBridge rule
5. The Lambda function detects the new image and updates the ECS service
6. The ECS service performs a rolling deployment of the new version

You can also manually trigger the workflow using GitHub Actions' workflow_dispatch event.