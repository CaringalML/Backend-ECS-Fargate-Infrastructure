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
