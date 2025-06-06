#!/bin/bash
set -e

echo "🚀 Initializing LocalStack S3..."

# Wait for LocalStack to be ready
until awslocal s3 ls; do
  echo "⏳ Waiting for LocalStack to be ready..."
  sleep 2
done

# Create buckets
echo "📦 Creating S3 buckets..."
awslocal s3 mb s3://${AWS_BUCKET_NAME}

# Set bucket policies/CORS if needed
echo "⚙️ Configuring bucket settings..."
awslocal s3api put-bucket-cors --bucket ${AWS_BUCKET_NAME} --cors-configuration '{
  "CORSRules": [
    {
      "AllowedHeaders": ["*"],
      "AllowedMethods": ["GET", "PUT", "POST", "DELETE", "HEAD"],
      "AllowedOrigins": ["*"],
      "MaxAgeSeconds": 3000
    }
  ]
}'

echo "✅ LocalStack S3 initialization completed!"
