data "google_storage_bucket_object_content" "management_folder_id" {
  name = "org_hierarchy/outputs/management_folder_id.txt"
  bucket = var.gcp_storage_bucket
}

data "google_storage_bucket_object_content" "application_folder_id" {
  name = "org_hierarchy/outputs/application_folder_id.txt"
  bucket = var.gcp_storage_bucket
}

module "host-project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.1"
  name                 = "host"
  project_id = "host"
  random_project_id    = true
  org_id               = var.org_id
  billing_account      = var.billing_account
  enable_shared_vpc_host_project = true
  folder_id = data.google_storage_bucket_object_content.management_folder_id.content
}

module "network" {
  source  = "terraform-google-modules/network/google"
  version = "4.0.1"
  network_name = "shared-vpc"
  project_id = module.host-project.project_id
  shared_vpc_host = true
  subnets = [
        {
            subnet_name           = "subnet-01"
            subnet_ip             = "10.0.0.0/24"
            subnet_region         = "us-west1"
        },
        {
            subnet_name           = "subnet-02"
            subnet_ip             = "10.0.1.0/24"
            subnet_region         = "us-west2"
        },
        {
            subnet_name           = "subnet-03"
            subnet_ip             = "10.0.2.0/24"
            subnet_region         = "us-east1"
            subnet_private_access = true
        },
        {
            subnet_name           = "subnet-04"
            subnet_ip             = "10.0.3.0/24"
            subnet_region         = "us-east4"
            subnet_private_access = true
        }
  ]
}
module "firewall_rules" {
  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  project_id   = module.host-project.project_id
  network_name = module.network.network_name

  rules = [{
    name                    = "allow-ssh-ingress"
    description             = null
    direction               = "INGRESS"
    priority                = null
    ranges                  = ["35.235.240.0/20"]
    source_tags             = null
    source_service_accounts = null
    target_tags             = ["openssh-server"]
    target_service_accounts = null
    allow = [{
      protocol = "tcp"
      ports    = ["22"]
    }]
    deny = []
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
  },
  {
    name                    = "allow-http-ingress"
    description             = null
    direction               = "INGRESS"
    priority                = null
    ranges                  = ["0.0.0.0/0"]
    source_tags             = null
    source_service_accounts = null
    target_tags             = ["http-server"]
    target_service_accounts = null
    allow = [{
      protocol = "tcp"
      ports    = ["80"]
    }]
    deny = []
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
  }]
}

resource "google_compute_global_address" "gcp_load_balancer_ip" {
  project = module.host-project.project_id
  name = "lb-external-ip"
  address_type = "EXTERNAL"  
}

resource "google_storage_bucket_object" "load-balancer-ip" {
  bucket = var.gcp_storage_bucket
  name = "compute/outputs/load-balancer-ip.txt"
  content = resource.google_compute_global_address.gcp_load_balancer_ip.ip_address
}


module "service-project" {
  depends_on = [
    module.host-project
  ]
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.1"
  name = "service"
  project_id = "service"
  random_project_id    = true
  org_id               = var.org_id
  billing_account      = var.billing_account
  folder_id = data.google_storage_bucket_object_content.application_folder_id.content
  svpc_host_project_id = module.host-project.project_id
}