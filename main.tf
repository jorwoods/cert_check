terraform {
  required_version = ">= 1.9"

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
    resources = [aws_sns_topic.this[count.index].arn]
  }
}

resource "aws_iam_policy" "this" {
  count  = var.enabled ? 1 : 0
  name   = "${var.prefix}-policy"
  policy = data.aws_iam_policy_document.this[count.index].json
}

resource "aws_iam_user" "this" {
  count = var.enabled ? 1 : 0
  name  = var.prefix
}

resource "aws_iam_user_policy_attachment" "user_assume_role" {
  count      = var.enabled ? 1 : 0
  user       = aws_iam_user.this[count.index].name
  policy_arn = aws_iam_policy.this[count.index].arn
}

resource "aws_iam_access_key" "this" {
  count = var.enabled ? 1 : 0
  user  = aws_iam_user.this[count.index].name
}

resource "aws_sns_topic" "this" {
  count = var.enabled ? 1 : 0
  name  = "${var.prefix}-topic"
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
      identifiers = [aws_iam_user.this[count.index].arn]
    }
  }
}
