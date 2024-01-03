#!/bin/bash

# Variables
AWS_REGION="eu-central-1"
ECR_REPO_NAME="llm-lambda"
IMAGE_TAG="latest"
LAMBDA_FUNCTION_NAME="llm-lambda"
LAMBDA_ROLE_NAME="llm-lambda-role" # Role name to create, not ARN
DOCKER_PLATFORM="linux/arm64" # Change as needed, e.g., linux/amd64
IAM_POLICY_FILE="trust-policy.json"
PAGER= # Disable pager for AWS CLI

# Authenticate with AWS
aws configure list # Optional, just to verify AWS CLI is configured

# Check if the ECR repository exists
REPO_EXISTS=$(aws ecr describe-repositories --repository-names $ECR_REPO_NAME --region $AWS_REGION 2>&1)

if [ $? -ne 0 ]; then
    echo "Repository does not exist. Creating repository: $ECR_REPO_NAME"
    # Create ECR repository
    aws ecr create-repository --repository-name $ECR_REPO_NAME --region $AWS_REGION
else
    echo "Repository $ECR_REPO_NAME already exists. Skipping creation."
fi

# Check if the Lambda IAM role exists
ROLE_EXISTS=$(aws iam get-role --role-name $LAMBDA_ROLE_NAME 2>&1)

if [ $? -ne 0 ]; then
    echo "IAM role does not exist. Creating role: $LAMBDA_ROLE_NAME"
    # Create IAM role for Lambda
    aws iam create-role --role-name $LAMBDA_ROLE_NAME --assume-role-policy-document file://$IAM_POLICY_FILE
    aws iam attach-role-policy --role-name $LAMBDA_ROLE_NAME --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
else
    echo "IAM role $LAMBDA_ROLE_NAME already exists. Skipping creation."
fi

# Get login command from ECR and execute it to authenticate Docker to the registry
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query Account --output text).dkr.ecr.$AWS_REGION.amazonaws.com

# Build the Docker image using Docker Compose with specific platform
DOCKER_BUILDKIT=1 docker-compose build --build-arg BUILDPLATFORM=$DOCKER_PLATFORM

# Tag the Docker image for ECR
docker tag llm-lambda:latest $(aws sts get-caller-identity --query Account --output text).dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:$IMAGE_TAG

# Push the Docker image to ECR
docker push $(aws sts get-caller-identity --query Account --output text).dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:$IMAGE_TAG

# Get the IAM role ARN
LAMBDA_ROLE_ARN=$(aws iam get-role --role-name $LAMBDA_ROLE_NAME --query 'Role.Arn' --output text)

# Check if Lambda function exists
FUNCTION_EXISTS=$(aws lambda get-function --function-name $LAMBDA_FUNCTION_NAME --region $AWS_REGION 2>&1)

# Parameters for Lambda function
LAMBDA_TIMEOUT=300 # 5 minutes in seconds
LAMBDA_MEMORY_SIZE=10240 # Maximum memory size in MB
LAMBDA_IMAGE_URI=$(aws sts get-caller-identity --query Account --output text).dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:$IMAGE_TAG

# Deploy or update the Lambda function
if echo $FUNCTION_EXISTS | grep -q "ResourceNotFoundException"; then
    echo "Creating new Lambda function: $LAMBDA_FUNCTION_NAME"
    aws lambda create-function --function-name $LAMBDA_FUNCTION_NAME \
        --region $AWS_REGION \
        --role $LAMBDA_ROLE_ARN \
        --timeout $LAMBDA_TIMEOUT \
        --memory-size $LAMBDA_MEMORY_SIZE \
        --package-type Image \
        --architectures arm64 \
        --code ImageUri=$LAMBDA_IMAGE_URI

    aws lambda create-function-url-config --function-name $LAMBDA_FUNCTION_NAME \
        --auth-type "NONE" --region $AWS_REGION

    # Add permission to allow public access to the Function URL
    aws lambda add-permission --function-name $LAMBDA_FUNCTION_NAME \
        --region $AWS_REGION \
        --statement-id "FunctionURLAllowPublicAccess" \
        --action "lambda:InvokeFunctionUrl" \
        --principal "*" \
        --function-url-auth-type "NONE"
else
    echo "Updating existing Lambda function: $LAMBDA_FUNCTION_NAME"
    aws lambda update-function-code --function-name $LAMBDA_FUNCTION_NAME \
        --region $AWS_REGION \
        --image-uri $LAMBDA_IMAGE_URI
fi

# Retrieve and print the Function URL
FUNCTION_URL=$(aws lambda get-function-url-config --region $AWS_REGION --function-name $LAMBDA_FUNCTION_NAME --query 'FunctionUrl' --output text)
echo "Lambda Function URL: $FUNCTION_URL"
