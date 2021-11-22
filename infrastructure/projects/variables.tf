variable "billing_account" {}

variable "region" {
  type = string
  default = "us-central1"
}

variable "org_id" {}

variable "gcp_storage_bucket" {
  type = string
  default = "danielsiefert-dev-terraform-storage"
}