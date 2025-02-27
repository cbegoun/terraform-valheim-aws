import boto3
import time
import json

ecs_client = boto3.client("ecs")

def check_players():
    # Replace with logic to check for active players
    # Example: Query Valheim logs or check network connections
    return False  # Return True if players are online, False otherwise

def lambda_handler(event, context):
    cluster_name = "valheim-cluster"
    service_name = "valheim-service"

    if not check_players():
        print("No players detected. Stopping server...")
        ecs_client.update_service(
            cluster=cluster_name,
            service=service_name,
            desiredCount=0  # Stop the server
        )
        return {"statusCode": 200, "body": "Server stopped due to inactivity."}
    
    return {"statusCode": 200, "body": "Players detected, keeping server running."}
