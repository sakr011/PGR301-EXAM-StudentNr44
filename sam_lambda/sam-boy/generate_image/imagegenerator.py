import base64
import boto3
import json
import random
import os

# AWS-klienter
bedrock_client = boto3.client("bedrock-runtime", region_name="us-east-1")
s3_client = boto3.client("s3")

# Henter miljøvariabler
bucket_name = os.environ["S3_BUCKET_NAME"]
candidate_number = os.environ["CANDIDATE_NUMBER"]

def lambda_handler(event, context):
    try:
        # Henter ut prompt fra forespørselens body
        body = json.loads(event["body"])
        prompt = body.get("prompt")
        if not prompt:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Prompt is required."})
            }

        # Generer unikt seed for bildet
        seed = random.randint(0, 2147483647)

        # Lag filsti i S3
        s3_image_path = f"{candidate_number}/generated_images/titan_{seed}.png"

        # Konfigurer forespørsel til bilde-generatoren
        native_request = {
            "taskType": "TEXT_IMAGE",
            "textToImageParams": {"text": prompt},
            "imageGenerationConfig": {
                "numberOfImages": 1,
                "quality": "standard",
                "cfgScale": 8.0,
                "height": 1024,
                "width": 1024,
                "seed": seed,
            }
        }

        # Generer bildet via Bedrock-modellen
        response = bedrock_client.invoke_model(
            modelId="amazon.titan-image-generator-v1", 
            body=json.dumps(native_request)
        )
        model_response = json.loads(response["body"].read())

        # Dekode bildet fra Base64
        base64_image_data = model_response["images"][0]
        image_data = base64.b64decode(base64_image_data)

        # Last opp bildet til S3
        s3_client.put_object(
            Bucket=bucket_name, 
            Key=s3_image_path, 
            Body=image_data
        )

        # Generer S3 URI for bildet
        s3_uri = f"s3://{bucket_name}/{s3_image_path}"

        # Returner respons
        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "An Image has been generated!",
                "image_uri": s3_uri
            })
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }