terraform {
  required_version = ">= 1.9"

  backend "s3" {
    bucket       = ""
    key          = ""
    region       = ""
    use_lockfile = true

  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.84.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "this" {}

data "aws_iam_policy_document" "this" {
  count = var.enabled ? 1 : 0
  statement {
    actions = [
      "sns:Publish",
      "sns:GetTopicAttributes",
      "sns:List*",
      "sns:GetSubscriptionAttributes",
    ]
    effect    = "Allow"
    resources = aws_sns_topic.this[*].arn
  }
}

resource "aws_iam_policy" "this" {
  count  = var.enabled ? 1 : 0
  name   = "${var.prefix}-policy"
  policy = one(data.aws_iam_policy_document.this[*].json)
}

resource "aws_iam_user" "this" {
  count = var.enabled ? 1 : 0
  name  = var.prefix
}

resource "aws_iam_user_policy_attachment" "user_assume_role" {
  count      = var.enabled ? 1 : 0
  user       = one(aws_iam_user.this[*].name)
  policy_arn = one(aws_iam_policy.this[*].arn)
}

resource "aws_iam_access_key" "this" {
  count = var.enabled ? 1 : 0
  user  = one(aws_iam_user.this[*].name)
}

resource "aws_sns_topic" "this" {
  count = var.enabled ? 1 : 0
  name  = "${var.prefix}-topic"
}

# https://docs.aws.amazon.com/sns/latest/dg/sns-access-policy-language-api-permissions-reference.html
data "aws_iam_policy_document" "sns_policy" {
  count = var.enabled ? 1 : 0
  statement {
    actions = [
      "sns:AddPermission",
      "sns:DeleteTopic",
      "sns:GetDataProtectionPolicy",
      "sns:GetTopicAttributes",
      "sns:ListSubscriptionsByTopic",
      "sns:ListTagsForResource",
      "sns:Publish",
      "sns:PutDataProtectionPolicy",
      "sns:RemovePermission",
      "sns:SetTopicAttributes",
      "sns:Subscribe",
    ]
    effect    = "Allow"
    resources = aws_sns_topic.this[*].arn
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"]
    }
  }
}

resource "aws_sns_topic_policy" "this" {
  count  = var.enabled ? 1 : 0
  arn    = one(aws_sns_topic.this[*].arn)
  policy = one(data.aws_iam_policy_document.sns_policy[*].json)
}

resource "aws_sns_topic_subscription" "this" {
  for_each  = var.enabled ? toset(var.subscribers) : toset([])
  topic_arn = one(aws_sns_topic.this[*].arn)
  protocol  = "email"
  endpoint  = each.value
}

data "aws_iam_policy_document" "assume_policy" {
  count = var.enabled ? 1 : 0
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "AWS"
      identifiers = aws_iam_user.this[*].arn
    }
  }
}
