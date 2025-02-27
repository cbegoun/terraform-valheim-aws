import boto3

ecs_client = boto3.client('ecs')

def lambda_handler(event, context):
    cluster_name = "valheim-cluster"
    service_name = "valheim-service"

    ecs_client.update_service(
        cluster=cluster_name,
        service=service_name,
        desiredCount=1
    )

    return {"statusCode": 200, "body": "Valheim server started"}
