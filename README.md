This repository contains the complete solution for provisioning, deploying, and monitoring the new internal analytics dashboard application on AWS. The entire infrastructure is managed using Terraform (Infrastructure as Code), and deployments are automated via a CI/CD pipeline using GitHub Actions.

1. Architecture Design
The application is deployed on a serverless, container-based architecture using AWS Elastic Container Service (ECS) with Fargate. This approach was chosen to eliminate the need for managing underlying server infrastructure, improve security, and provide seamless scaling.
Core Components
Networking: A new VPC is created with public subnets, an Internet Gateway, and proper route tables.

Compute: AWS ECS with Fargate runs the Docker containers.

Load Balancing & Security: An Application Load Balancer (ALB) handles HTTPS traffic, with authentication managed by AWS Cognito.

Container Registry: Amazon ECR repositories store the Docker images.

CI/CD: A GitHub Actions workflow automates build and deployment.

Observability: Amazon CloudWatch provides metrics and alerting via an SNS topic.