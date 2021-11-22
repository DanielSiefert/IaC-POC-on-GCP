resource "google_compute_instance" "redhat-vm1" {
  project = var.project_id
  zone = "us-west1-a"
  name = "redhat-vm1"
  tags = ["openssh-server"]
  machine_type = "e2-small"
  allow_stopping_for_update = true
  shielded_instance_config {
    enable_secure_boot = true
    enable_vtpm = true
    enable_integrity_monitoring = true
  }
  
  boot_disk {
    initialize_params {
      image = "rhel-7-v20211105"
      size = 20
      type = "pd-standard"
    }
  }

  network_interface {
    subnetwork = "projects/host-5d52/regions/us-west1/subnetworks/subnet-01"
  }
}

resource "google_compute_instance" "redhat-vm2" {
  project = var.project_id
  zone = "us-east1-b"
  name = "redhat-vm2"
  tags = ["openssh-server","http-server"]
  machine_type = "e2-medium"
  allow_stopping_for_update = true
  shielded_instance_config {
    enable_secure_boot = true
    enable_vtpm = true
    enable_integrity_monitoring = true
  }
  
  boot_disk {
    initialize_params {
      image = "rhel-7-v20211105"
      size = 20
      type = "pd-standard"
    }
  }

  network_interface {
    subnetwork = "projects/host-5d52/regions/us-east1/subnetworks/subnet-03"
  }

  metadata_startup_script = file("./startup-script.sh")
}

#TODO: add bastion host setup for 2nd VM.