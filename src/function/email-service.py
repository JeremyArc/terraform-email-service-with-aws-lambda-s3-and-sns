import boto3
import csv
import os
from io import StringIO

s3 = boto3.client('s3')
sns = boto3.client('sns')

sns_topic_arn = os.getenv('SNS_TOPIC_ARN', 'default_arn_if_not_set')

print('sns_topic_arn', sns_topic_arn)

def handler(event, context):
    
    print('event', event) 
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    object_key = event['Records'][0]['s3']['object']['key']
    
    print("Bucket name:", bucket_name)
    print("Object key:", object_key)

    if bucket_name == 'lambda-emailing-service':
        email_data = read_csv_from_s3(bucket_name, object_key)

        if email_data:
            send_emails(email_data)

def read_csv_from_s3(bucket_name, object_key):
    email_data = []

    try:
        response = s3.get_object(Bucket=bucket_name, Key=object_key)
        csv_data = response['Body'].read().decode('utf-8')

        reader = csv.DictReader(StringIO(csv_data))
        for row in reader:
            topic = row['topic']
            message = row['message']

            email = {
                'topic': topic,
                'message': message
            }
            
            print("email: ", email)

            email_data.append(email)
    except Exception as e:
        print('Error reading CSV file from S3:', e)

    return email_data

def send_emails(email_data):
    try:
        for email in email_data:
            message = f"Subject: {email['topic']}\n\n{email['message']}"
            response = sns.publish(
                TopicArn=sns_topic_arn,
                Message=message
            )
            print('Email sent to SNS topic:', response['MessageId'])
    except Exception as e:
        print('Error sending email:', e)