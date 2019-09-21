

provider "google" {
  project = "learned-hour-252201"
  region  = "us-central1"
  zone    = "us-central1-a"
}

resource "google_compute_instance" "instance-2" {
  name         = "terraform-instance"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "debian-9-stretch-v20190905"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network       = "default"
    access_config {
    }
  }
}

resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = "true"
}

