import boto3
import datetime
import subprocess

s3_client = boto3.client('s3')

def lambda_handler(event, context):
    bucket_name = "valheim-backup-bucket"
    backup_file = f"/tmp/valheim_backup_{datetime.datetime.utcnow().strftime('%Y%m%d%H%M%S')}.tar.gz"

    subprocess.run(["tar", "-czf", backup_file, "/path/to/valheim/world"], check=True)

    s3_client.upload_file(backup_file, bucket_name, f"backups/{backup_file.split('/')[-1]}")

    return {"statusCode": 200, "body": "Backup completed"}
