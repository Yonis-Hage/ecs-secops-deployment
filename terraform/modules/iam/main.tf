resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# Trust policy template
data "aws_iam_policy_document" "assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_repo}:ref:refs/heads/*",
        "repo:${var.github_repo}:ref:refs/pull/*"
      ]
    }
  }
}

# Plan Role (read-only)
resource "aws_iam_role" "plan" {
  name               = "gha-plan-${replace(var.github_repo, "/", "-")}"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

# Apply Role (write)
resource "aws_iam_role" "apply" {
  name               = "gha-apply-${replace(var.github_repo, "/", "-")}"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

# Policies for state, ECR, ECS
data "aws_iam_policy_document" "tf_state_read" {
  statement {
    actions = ["s3:GetObject", "s3:ListBucket"]
    resources = [
      "arn:aws:s3:::${var.tf_state_bucket}",
      "arn:aws:s3:::${var.tf_state_bucket}/*"
    ]
  }
  statement {
    actions   = ["dynamodb:GetItem", "dynamodb:DescribeTable"]
    resources = [var.dynamodb_lock_table_arn]
  }
}

resource "aws_iam_policy" "tf_state_read" {
  name   = "tf-state-read"
  policy = data.aws_iam_policy_document.tf_state_read.json
}

# Full TF state policy (for apply)
data "aws_iam_policy_document" "tf_state_full" {
  statement {
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::${var.tf_state_bucket}",
      "arn:aws:s3:::${var.tf_state_bucket}/*"
    ]
  }
  statement {
    actions   = ["dynamodb:*"]
    resources = [var.dynamodb_lock_table_arn]
  }
}

resource "aws_iam_policy" "tf_state_full" {
  name   = "tf-state-full"
  policy = data.aws_iam_policy_document.tf_state_full.json
}

# Attachments
resource "aws_iam_role_policy_attachment" "plan_tf" {
  role       = aws_iam_role.plan.name
  policy_arn = aws_iam_policy.tf_state_read.arn
}

resource "aws_iam_role_policy_attachment" "apply_tf" {
  role       = aws_iam_role.apply.name
  policy_arn = aws_iam_policy.tf_state_full.arn
}
