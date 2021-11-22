terraform {
    backend "gcs" {
        bucket = "danielsiefert-dev-terraform-storage"
        prefix = "terraform/lb"
    }

}

provider "google" {
    region = var.region
}
