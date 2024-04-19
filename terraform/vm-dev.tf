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
      size  = 30
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
    automatic_restart   = false
    on_host_maintenance = "TERMINATE"
    provisioning_model  = "STANDARD"
    preemptible         = false
  }
  service_account {
    email  = google_service_account.team[each.key].email
    scopes = ["cloud-platform"]
  }
  // ignore changes to current status and cpu_platform
  lifecycle {
    ignore_changes = [
      machine_type,
      boot_disk,
      metadata,
    ]
  }
}

resource "google_compute_instance" "big-disk-vm" {
  name         = "big-disk-dev"
  machine_type = "n2d-standard-4"
  zone         = "${local.region}-b"
  labels = {
    app     = "big-disk-dev"
    version = "ubuntu-2204"
    disk    = "raid0"
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    # does this create a strange chicken and the egg problem?
    sudo mdadm --create /dev/md0 --level=0 --raid-devices=4 \
      /dev/disk/by-id/google-local-nvme-ssd-0 \
      /dev/disk/by-id/google-local-nvme-ssd-1 \
      /dev/disk/by-id/google-local-nvme-ssd-2 \
      /dev/disk/by-id/google-local-nvme-ssd-3
    sudo mkfs.ext4 -F /dev/md0
    sudo mkdir -p /mnt/data
    sudo mount /mnt/data
    sudo chmod 0777 /mnt/data
  EOF

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 30
    }
    auto_delete = false
  }
  // https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance
  scratch_disk { interface = "NVME" }
  scratch_disk { interface = "NVME" }
  scratch_disk { interface = "NVME" }
  scratch_disk { interface = "NVME" }

  network_interface {
    network = "default"
    access_config {}
  }
  scheduling {
    automatic_restart   = false
    on_host_maintenance = "TERMINATE"
    provisioning_model  = "STANDARD"
    preemptible         = false
  }
  service_account {
    scopes = ["cloud-platform"]
  }
  // ignore changes to current status and cpu_platform
  lifecycle {
    ignore_changes = [
      machine_type,
      boot_disk,
      metadata,
    ]
  }
}

// https://cloud.google.com/compute/docs/gpus/gpu-regions-zones
// https://cloud.google.com/compute/gpus-pricing
resource "google_compute_instance" "regional-gpu" {
  for_each = {
    us-east1-d = "g2-standard-4",
    us-east4-a = "g2-standard-4",
    us-west1-b = "g2-standard-4",
    # us-west2-c="n1-standard-4",
    # us-west3-b="a2-standard-4",
    us-west4-a = "g2-standard-4",
  }
  name         = "regional-gpu-dev-${each.key}"
  machine_type = each.value
  zone         = each.key
  labels = {
    disk    = "raid0"
    app     = "regional-gpu-dev"
    version = "ubuntu-2204"
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    # does this create a strange chicken and the egg problem?
    sudo mdadm --create /dev/md0 --level=0 --raid-devices=1 \
      /dev/disk/by-id/google-local-nvme-ssd-0
    sudo mkfs.ext4 -F /dev/md0
    sudo mkdir -p /mnt/data
    sudo mount /mnt/data
    sudo chmod 0777 /mnt/data
  EOF

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 30
    }
    auto_delete = false
  }
  // https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance
  scratch_disk { interface = "NVME" }

  network_interface {
    network = "default"
    access_config {}
  }
  scheduling {
    automatic_restart   = false
    on_host_maintenance = "TERMINATE"
    provisioning_model  = "STANDARD"
    preemptible         = false
  }
  service_account {
    scopes = ["cloud-platform"]
  }
  // ignore changes to current status and cpu_platform
  lifecycle {
    ignore_changes = [
      machine_type,
      boot_disk,
      metadata,
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
  cors {
    origin          = ["*"]
    method          = ["GET"]
    response_header = ["*"]
    max_age_seconds = 3600
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
