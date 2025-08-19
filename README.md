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

Architecture Diagram:

graph TD
    subgraph "Internet"
        User[End User]
    end

    subgraph "AWS Cloud"
        DNS[Route 53] -->|Alias Record| ALB[Application Load Balancer]

        subgraph "VPC"
            ALB -- HTTPS/443 --> TG[Target Group]
            TG --> FargateTask[ECS Fargate Task]

            subgraph FargateTask
                Frontend[Frontend Container<br>(React)]
                Backend[Backend Container<br>(Node.js API)]
            end
        end

        subgraph "Monitoring & Alerting"
             FargateTask -- Metrics --> CW[CloudWatch Metrics]
             CW -- CPU > 70% --> Alarm[CloudWatch Alarm]
             Alarm -- Triggers --> SNS[SNS Topic]
             SNS -- Notifies --> Email[Admin Email]
        end

        subgraph "CI/CD Pipeline"
             GH[GitHub Repo] -- on push to main --> GHA[GitHub Actions]
             GHA -- Builds & Pushes --> ECR[ECR Repositories<br>Frontend & Backend Images]
             GHA -- Deploys --> FargateTask
        end

        subgraph "Security"
             ACM[AWS Certificate Manager<br>TLS Certificate] --> ALB
             ALB -- Authenticates --> Cognito[Cognito User Pool]
        end
    end

    User -- HTTPS Request --> DNS
