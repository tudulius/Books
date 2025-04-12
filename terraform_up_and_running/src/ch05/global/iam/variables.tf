variable "user_names" {
  type        = list(any)
  description = "create iam users with three names"
  default     = ["gurumee", "brenden", "ingoo"]
}

variable "give_gurumee_cloudwatch_full_access" {
  type        = bool
  description = "If true, gurumee gets full access to cloudWatch"
  default     = true
}