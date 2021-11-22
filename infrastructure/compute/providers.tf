terraform {
    backend "gcs" {
        bucket = "danielsiefert-dev-terraform-storage"
        prefix = "terraform/compute"
    }

}

provider "google" {
    region = var.region
}
