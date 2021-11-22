terraform {
    backend "gcs" {
        bucket = "danielsiefert-dev-terraform-storage"
        prefix = "terraform/org_hierarchy"
    }

}

provider "google" {
    credentials = file("~/.config/secrets/${var.project_id}.json")
    project = var.project_id
}
