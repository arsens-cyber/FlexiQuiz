#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Script Variables ---
# These are passed as arguments from the GitHub Actions workflow
ECS_CLUSTER=$1
ECS_SERVICE=$2
FRONTEND_IMAGE_URI=$3
BACKEND_IMAGE_URI=$4
CONTAINER_FRONTEND_NAME=$5
CONTAINER_BACKEND_NAME=$6

echo "Starting deployment for service $ECS_SERVICE in cluster $ECS_CLUSTER..."

# --- Download and Update Task Definition ---
echo "1. Downloading current task definition..."
# Get the current task definition, saving it to a file
aws ecs describe-task-definition --task-definition "$ECS_SERVICE" --query taskDefinition > task-definition.json

echo "2. Creating new task definition with updated image URIs..."
# Use jq to update the image for both the frontend and backend containers
# This creates a new JSON file for the new revision
cat task-definition.json | jq \
  --arg FRONTEND_IMAGE "$FRONTEND_IMAGE_URI" \
  --arg BACKEND_IMAGE "$BACKEND_IMAGE_URI" \
  --arg CONTAINER_FRONTEND "$CONTAINER_FRONTEND_NAME" \
  --arg CONTAINER_BACKEND "$CONTAINER_BACKEND_NAME" \
  '.containerDefinitions |= map(
    if .name == $CONTAINER_FRONTEND then .image = $FRONTEND_IMAGE
    elif .name == $CONTAINER_BACKEND then .image = $BACKEND_IMAGE
    else . end
  )' \
  | jq 'del(.taskDefinitionArn, .revision, .status, .requiresAttributes, .compatibilities, .registeredAt, .registeredBy)' \
  > new-task-definition.json

echo "New task definition content:"
cat new-task-definition.json

# --- Register New Task Definition and Deploy ---
echo "3. Registering the new task definition..."
# Register the new task definition and capture the output
NEW_TASK_DEF_OUTPUT=$(aws ecs register-task-definition --cli-input-json file://new-task-definition.json)
# Extract the new task definition ARN from the output
NEW_TASK_DEF_ARN=$(echo "$NEW_TASK_DEF_OUTPUT" | jq -r '.taskDefinition.taskDefinitionArn')
echo "Successfully registered new task definition: $NEW_TASK_DEF_ARN"

echo "4. Updating the ECS service to use the new task definition..."
aws ecs update-service \
  --cluster "$ECS_CLUSTER" \
  --service "$ECS_SERVICE" \
  --task-definition "$NEW_TASK_DEF_ARN" \
  --force-new-deployment

echo "5. Waiting for deployment to complete..."
aws ecs wait services-stable --cluster "$ECS_CLUSTER" --services "$ECS_SERVICE"

echo "Deployment successful for service $ECS_SERVICE!"