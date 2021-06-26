
variable "repositories" {
  type = list(string)
}

variable "kms_key" {
  type = string
}

variable "tags" {
  type = map(string)
}
