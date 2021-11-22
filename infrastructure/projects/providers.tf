terraform {
    backend "gcs" {
        bucket = "danielsiefert-dev-terraform-storage"
        prefix = "terraform/projects"
    }

}

provider "google" {
    region = var.region
}
