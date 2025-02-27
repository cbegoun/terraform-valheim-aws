import boto3

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    instance_id = 'i-xxxxxxxxxxxx'  # Replace with your instance ID
    ec2.stop_instances(InstanceIds=[instance_id])
    return {
        'statusCode': 200,
        'body': f"Stopped instance: {instance_id}"
    }