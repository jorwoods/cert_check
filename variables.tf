variable "enabled" {
  description = "value to enable or disable resources"
  type        = bool
  default     = true
}

variable "prefix" {
  description = "prefix to add to resources"
  type        = string
  default     = "cert-check"

}

variable "subscribers" {
  type        = list(string)
  default     = []
  description = "List of email addresses to subscribe to the SNS topic"
}
