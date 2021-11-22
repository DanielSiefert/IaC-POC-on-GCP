module "folders" {
  source  = "terraform-google-modules/folders/google"
  version = "3.0.0"
  parent = "organizations/${var.org_id}"
  names = ["management", "application"]
}

resource "google_storage_bucket_object" "management_folder_id" {
  bucket = var.gcp_storage_bucket
  name = "org_hierarchy/outputs/management_folder_id.txt"
  content = module.folders.ids_list[0]
}

resource "google_storage_bucket_object" "application_folder_id" {
  bucket = var.gcp_storage_bucket
  name = "org_hierarchy/outputs/application_folder_id.txt"
  content = module.folders.ids_list[1]
}