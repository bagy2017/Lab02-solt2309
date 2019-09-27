

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
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network       = "default"
    access_config {
    }
  }

  provisioner "remote-exec" {
    connection {
      host        = "${google_compute_instance.svc-1.network_interface.0.access_config.0.nat_ip}"
      user        = "solt2309"
      type        = "ssh"
      private_key = "${file("~/.ssh/google_compute_engine")}"
      }
    inline = [
      "mkdir -p ~/svc-01/html",
    ]
  }

  provisioner "file" {
    source      = "svc-01/"
    destination = "~/svc-01"
    connection {
      host        = "${google_compute_instance.svc-1.network_interface.0.access_config.0.nat_ip}"
      user        = "solt2309"
      type        = "ssh"
      private_key = "${file("~/.ssh/google_compute_engine")}"
    }
  }

  provisioner "remote-exec" {
    connection {
      host        = "${google_compute_instance.svc-1.network_interface.0.access_config.0.nat_ip}"
      user        = "solt2309"
      type        = "ssh"
      private_key = "${file("~/.ssh/google_compute_engine")}"
      }
    inline = [ 
      "chmod +x ~/svc-01/install.sh",
      "sudo ~/svc-01/install.sh",
    ]
  }

  #service account is essential for file provisioner
  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }

}

resource "google_compute_firewall" "default" {
 name    = "svc01-firewall"
 network = "default"

 allow {
   protocol = "tcp"
   ports    = ["80"]
 }
}

output "ip" {
   value = "${google_compute_instance.svc-1.network_interface.0.access_config.0.nat_ip}"
}

