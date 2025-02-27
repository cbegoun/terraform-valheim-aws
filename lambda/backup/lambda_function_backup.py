import boto3
import os
import datetime

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    s3 = boto3.client('s3')
    instance_id = os.environ['INSTANCE_ID']
    bucket_name = os.environ['BUCKET_NAME']
    
    # Create an image of the instance
    image = ec2.create_image(InstanceId=instance_id, Name=f"valheim-backup-{datetime.datetime.now().strftime('%Y%m%d%H%M%S')}")
    
    # Store the image in the S3 bucket
    s3.put_object(Bucket=bucket_name, Key=f"backups/{image['ImageId']}.txt", Body=image['ImageId'])
    
    return {
        'statusCode': 200,
        'body': f"Backup created: {image['ImageId']}"
    }