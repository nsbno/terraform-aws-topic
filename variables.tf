variable "name" {
  description = "The name of the topic"

  type = string
}

variable "allowed_external_subscribers" {
  description = "A list of account IDs that are allowed to subscribe to the topic"

  type    = list(string)
  default = []
}

variable "create_payload_bucket" {
  description = "Create an S3 bucket where large messages can be placed"

  type    = bool
  default = false
}

variable "payload_bucket_expiration_days" {
  description = "The amount of days a message will be stored in the payload bucket"

  type    = number
  default = 7
}
