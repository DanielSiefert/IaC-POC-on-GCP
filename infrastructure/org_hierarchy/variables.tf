variable "org_id" {
    type = string
  
}
variable "project_id" {
  type = string
  default = "danielsiefert-dev-terraform"
}

variable "gcp_storage_bucket" {
  type = string
  default = "danielsiefert-dev-terraform-storage"
}
