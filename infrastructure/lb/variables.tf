variable "billing_account" {}

variable "region" {
  type = string
  default = "us-central1"
}

variable "org_id" {}

variable "project_id" {
  type = string
  default = "service-c58d"
}

variable "gcp_storage_bucket" {
  type = string
  default = "danielsiefert-dev-terraform-storage"
}