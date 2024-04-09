module "topic" {
  source = "../../"

  name = "my-cool-topic"

  # This allows anyone in the VY organization to subscribe to this topic
  allow_anyone_in_organization_to_subscribe = true
  # This allows any of these specific accounts to subscribe
  allowed_external_subscribers = ["184682413771", "061938725231"]
}
