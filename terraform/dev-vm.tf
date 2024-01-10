// define the base vm instance for developers

locals {
  teams = [
    "geolifeclef",
    "birdclef",
    "plantclef",
    "snakeclef",
    "fungiclef",
    "idpp",
    "touche",
    "erisk",
    "bioasq",
    "pan",
  ]
}

resource "google_compute_instance" "dev-vm" {
  for_each     = toset(local.teams)
  name         = "${each.key}-dev"
  machine_type = "n1-standard-4"
  zone         = "${local.region}-a"
  labels = {
    app     = "dev"
    version = "ubuntu-2204"
    team    = each.key
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
    }
    auto_delete = false
  }
  // https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance
  scratch_disk {
    interface = "NVME"
  }
  network_interface {
    network = "default"
    access_config {
    }
  }
  scheduling {
    automatic_restart           = false
    instance_termination_action = "STOP"
    on_host_maintenance         = "TERMINATE"
    provisioning_model          = "SPOT"
    preemptible                 = true
  }
  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["cloud-platform"]
  }
  // ignore changes to current status and cpu_platform
  lifecycle {
    ignore_changes = [
      machine_type
    ]
  }
}

resource "google_storage_bucket" "team-bucket" {
  for_each = toset(local.teams)
  name     = "${local.owner}-${each.key}-2024"
  location = "US"
}
