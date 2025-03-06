variable "name" {
  description = "The name of the topic"

  type = string

  validation {
    condition     = !can(regex("\\.fifo$", var.name))
    error_message = "Use the is_fifo variable to create a FIFO topic."
  }
}

variable "allowed_external_subscribers" {
  description = "A list of account IDs that are allowed to subscribe to the topic"

  type    = list(string)
  default = []
}

variable "allow_anyone_in_organization_to_subscribe" {
  description = "Allow anyone within the current AWS organization to subscribe to the topic"

  type    = bool
  default = false
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

variable "is_fifo" {
  description = "Create a FIFO topic"

  type    = bool
  default = false
}

variable "use_content_based_deduplication" {
  description = "Enables content-based deduplication for FIFO topic"

  type    = bool
  default = false
}
