// define a e2-micro instance to run luigi
resource "google_compute_instance" "services" {
  name         = "services"
  machine_type = "e2-small"
  zone         = "${local.region}-a"
  labels = {
    app = "services"
  }
  tags                      = ["http-server", "https-server"]
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 10
    }
  }
  network_interface {
    network = "default"
    access_config {
    }
  }
  scheduling {
    automatic_restart  = true
    provisioning_model = "STANDARD"
  }
  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["cloud-platform"]
  }
}

output "services-vm" {
  value = {
    id          = google_compute_instance.services.id
    external_ip = google_compute_instance.services.network_interface.0.access_config.0.nat_ip
  }
}
