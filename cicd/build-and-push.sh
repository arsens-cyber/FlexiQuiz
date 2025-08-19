#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Script Variables ---
# These are passed as arguments from the GitHub Actions workflow
AWS_REGION=$1
ECR_REGISTRY=$2
ECR_REPOSITORY=$3
IMAGE_TAG=$4
DOCKERFILE_PATH=$5

# --- Log in to ECR ---
echo "Logging in to Amazon ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY
echo "Login successful."

# --- Build and Push Docker Image ---
FULL_IMAGE_NAME="$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG"

echo "Building Docker image: $FULL_IMAGE_NAME"
docker build -t $FULL_IMAGE_NAME -f $DOCKERFILE_PATH .

echo "Pushing Docker image to ECR: $FULL_IMAGE_NAME"
docker push $FULL_IMAGE_NAME

echo "Build and push complete for $FULL_IMAGE_NAME"

# Output the full image name so it can be used by subsequent steps in the pipeline
echo "image_uri=$FULL_IMAGE_NAME" >> "$GITHUB_OUTPUT"