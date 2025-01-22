output "iam_access_key" {
  value = one(aws_iam_access_key.this[*].id)

}

output "iam_secret_key" {
  value     = one(aws_iam_access_key.this[*].secret)
  sensitive = true
}

output "topic" {
  value = one(aws_sns_topic.this[*].arn)
}
