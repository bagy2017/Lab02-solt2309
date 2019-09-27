

provider "google" {
  project = "learned-hour-252201"
  region  = "us-central1"
  zone    = "us-central1-a"
}

resource "google_compute_instance" "svc-1" {
  name         = "solt2309-testvm1"
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
