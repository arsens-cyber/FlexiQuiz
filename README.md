This repository contains the complete solution for provisioning, deploying, and monitoring the new internal analytics dashboard application on AWS. The entire infrastructure is managed using Terraform (Infrastructure as Code), and deployments are automated via a CI/CD pipeline using GitHub Actions.

PLEASE NOTE - For the purpose of this "real work challenge" I need to point that I don't have access to AWS with IAM roles in my home environment, so it is not viable for me to create needed outside work environment. I provided a mockup for the purpose of this exercise.

1. Architecture Design
The application is deployed on a serverless, container-based architecture using AWS Elastic Container Service (ECS) with Fargate. This approach was chosen to eliminate the need for managing underlying server infrastructure, improve security, and provide seamless scaling.

Core Components
Networking: A new VPC is created with public subnets, an Internet Gateway, and proper route tables to ensure resources are isolated but accessible.

Compute: AWS ECS with Fargate runs the Docker containers. This serverless option means we don't manage any EC2 instances. The service is configured to run one task containing both the frontend and backend containers.

Load Balancing & Security:

An Application Load Balancer (ALB) serves as the public entry point. It's configured to only accept HTTPS traffic (port 443) and redirects HTTP traffic to HTTPS.

TLS/SSL is handled by a free certificate from AWS Certificate Manager (ACM).

Authentication is implemented at the ALB level using an integration with AWS Cognito. This provides a robust and secure way to protect the application, satisfying the "basic authentication" requirement with a modern, superior solution. Unauthenticated users are denied access directly at the edge.

Container Registry: Two Amazon ECR repositories are created to store the Docker images for the frontend and backend applications.

CI/CD: A GitHub Actions workflow triggers on every push to the main branch. It builds the Docker images, pushes them to ECR, and updates the ECS service to deploy the new version, ensuring zero-downtime deployments.

Observability: Amazon CloudWatch automatically collects metrics from the ECS service. A CloudWatch Alarm is configured to trigger if the average CPU utilization exceeds 70% for 5 consecutive minutes. The alarm sends a notification to an SNS Topic, which then emails the configured administrator.

rerequisites
An AWS Account with appropriate IAM permissions.

Terraform CLI installed.

A registered domain name managed via AWS Route 53.

A GitHub repository forked from this one.

Step 1: Configure GitHub Secrets
The CI/CD pipeline requires an IAM Role ARN to securely connect to AWS.

Navigate to your GitHub repository -> Settings -> Secrets and variables -> Actions.

Create a new repository secret named AWS_IAM_ROLE_ARN with the ARN of the IAM role created by Terraform (see terraform output cicd_iam_role_arn).

Step 2: Provision Infrastructure with Terraform
Clone the repository.

Navigate to the /infrastructure directory.

Create a terraform.tfvars file and provide values for the variables defined in variables.tf. At a minimum, you will need:

aws_region           = "us-east-1"
project_name         = "internal-dashboard"
environment          = "staging"
domain_name          = "your-domain.com" // e.g., example.com
dashboard_subdomain  = "dashboard-staging" // will create dashboard-staging.your-domain.com
admin_email          = "your-email@example.com" // for SNS alerts

Initialize and apply Terraform:

terraform init
terraform apply

Terraform will provision all the necessary resources. Note the outputs, especially the Cognito user pool details and the application URL. You will need to confirm the SNS email subscription sent to your admin_email.

Step 3: Create a User in Cognito
Go to the AWS Cognito console.

Find the user pool named internal-dashboard-staging-user-pool.

Create a new user. You will set a temporary password which you'll be prompted to change on first login.

Step 4: Trigger Deployment
Make a change to the application code and push the commit to the main branch. This will automatically trigger the GitHub Actions workflow, which will build and deploy the application. You can monitor the progress in the "Actions" tab of your repository.

Once the pipeline succeeds, the dashboard will be available at the URL provided in the Terraform outputs.
