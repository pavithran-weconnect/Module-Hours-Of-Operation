# Reserved for future: centralized tag strategy.
# Typically you'd add outputs.tf and call this as a module.

locals {
  default_tags = {
    ManagedBy = "Terraform"
  }
}
