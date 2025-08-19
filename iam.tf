# Role for ECS tasks to pull images from ECR and send logs to CloudWatch
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${local.name_prefix}-ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM Role for GitHub Actions CI/CD pipeline (using OIDC)
data "aws_iam_policy_document" "github_oidc_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      # IMPORTANT: Update this with your GitHub username/organization and repository name
      values   = ["repo:YourGitHubUsername/your-repo-name:ref:refs/heads/main"]
    }
  }
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"] # Standard thumbprint for GitHub OIDC
}


resource "aws_iam_role" "cicd_role" {
  name                  = "${local.name_prefix}-cicd-role"
  assume_role_policy    = data.aws_iam_policy_document.github_oidc_assume_role.json
  description           = "IAM Role for GitHub Actions CI/CD"
}

# Policy allowing CI/CD to push to ECR and update ECS
data "aws_iam_policy_document" "cicd_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage"
    ]
    resources = [
      aws_ecr_repository.frontend.arn,
      aws_ecr_repository.backend.arn
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["ecs:UpdateService"]
    resources = [aws_ecs_service.main.id]
  }
}

resource "aws_iam_policy" "cicd_policy" {
  name   = "${local.name_prefix}-cicd-policy"
  policy = data.aws_iam_policy_document.cicd_policy.json
}

resource "aws_iam_role_policy_attachment" "cicd_attach" {
  role       = aws_iam_role.cicd_role.name
  policy_arn = aws_iam_policy.cicd_policy.arn
}