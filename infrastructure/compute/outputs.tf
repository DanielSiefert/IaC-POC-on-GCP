resource "google_storage_bucket_object" "redhat-vm2-name" {
  bucket = var.gcp_storage_bucket
  name = "compute/outputs/redhat-vm2-name.txt"
  content = resource.google_compute_instance.redhat-vm2.name
}

resource "google_storage_bucket_object" "redhat-vm2-ip" {
  bucket = var.gcp_storage_bucket
  name = "compute/outputs/redhat-vm2-ip.txt"
  content = resource.google_compute_instance.redhat-vm2.network_interface[0].network_ip
}

