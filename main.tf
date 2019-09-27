
provider "google" {
  project = "learned-hour-252201"
  region  = "us-central1"
  zone    = "us-central1-a"
}

resource "google_compute_instance" "svc-1" {
  name         = "bagysn-testvm1"
  machine_type = "f1-micro"
  zone         = "us-central1-a"

  metadata = {
    ssh-keys = "bagysn:${file("~/.ssh/google_compute_engine.pub")}"
   }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  provisioner "remote-exec" {
    connection {
        host        = "${google_compute_instance.svc-1.network_interface.0.access_config.0.nat_ip}"
        user        = "bagysn"
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
      user        = "bagysn"
      type        = "ssh"
      private_key = "${file("~/.ssh/google_compute_engine")}"
    }
  }

  provisioner "remote-exec" {
    connection {
        host        = "${google_compute_instance.svc-1.network_interface.0.access_config.0.nat_ip}"
        user        = "bagysn"
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
