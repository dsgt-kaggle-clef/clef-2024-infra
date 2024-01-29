// create a service account for each team
resource "google_service_account" "team" {
  for_each     = toset(local.teams)
  account_id   = "dsgt-clef-${each.key}"
  display_name = each.key
}

// define the base vm instance for developers
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

  metadata_startup_script = <<-EOF
    #!/bin/bash
    # does this create a strange chicken and the egg problem?
    sudo mkfs.ext4 -F /dev/nvme0n1
    sudo mkdir -p /mnt/data
    sudo mount /mnt/data
    sudo chmod 0777 /mnt/data
  EOF

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
    email  = google_service_account.team[each.key].email
    scopes = ["cloud-platform"]
  }
  // ignore changes to current status and cpu_platform
  lifecycle {
    ignore_changes = [
      machine_type,
      boot_disk
    ]
  }
}

resource "google_storage_bucket" "team-bucket" {
  for_each = toset(local.teams)
  name     = "${local.owner}-${each.key}-2024"
  location = local.region
  labels = {
    team = each.key
  }
}


// now give each team access to their bucket
resource "google_storage_bucket_iam_binding" "team-bucket-admin" {
  for_each = toset(local.teams)
  bucket   = google_storage_bucket.team-bucket[each.key].name
  role     = "roles/storage.admin"
  members = [
    "serviceAccount:${google_service_account.team[each.key].email}",
    local.members[each.key]
  ]
}

// also grant storage viewer to the service account
resource "google_project_iam_member" "team-storage-viewer" {
  for_each = toset(local.teams)
  project  = local.project_id
  role     = "roles/storage.objectViewer"
  member   = "serviceAccount:${google_service_account.team[each.key].email}"
}
