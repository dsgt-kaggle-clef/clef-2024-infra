terraform {
  backend "gcs" {
    bucket = "dsgt-clef-2024-tfstate"
    prefix = "dsgt-clef-2024-infra"
  }
}

locals {
  project_id = "dsgt-clef-2024"
  region     = "us-central1"
  repo_name  = "clef-2024-infra"
  owner      = "dsgt-clef"
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
    "longeval",
  ]
}

provider "google" {
  project = local.project_id
  region  = local.region
}

data "google_project" "project" {}

resource "google_project_service" "default" {
  for_each = toset([
    "artifactregistry",
    "run",
    "cloudbuild",
    "iam",
    "cloudkms",
    "secretmanager",
    "batch",
  ])
  service = "${each.key}.googleapis.com"
}

// get the compute engine default service account
data "google_compute_default_service_account" "default" {
  project = local.project_id
}

resource "google_artifact_registry_repository" "infra" {
  location      = local.region
  repository_id = "infra"
  format        = "DOCKER"
  depends_on    = [google_project_service.default["artifactregistry"]]
}

// grant the compute engine default service account push access to the artifact registry
resource "google_artifact_registry_repository_iam_member" "infra" {
  repository = google_artifact_registry_repository.infra.name
  location   = google_artifact_registry_repository.infra.location
  role       = "roles/artifactregistry.repoAdmin"
  member     = "serviceAccount:${data.google_compute_default_service_account.default.email}"
}

resource "google_storage_bucket" "default" {
  name     = local.project_id
  location = "US"
  versioning {
    enabled = true
  }
  lifecycle_rule {
    condition {
      num_newer_versions = 3
    }
    action {
      type = "Delete"
    }
  }
  cors {
    origin          = ["*"]
    method          = ["GET"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}

// dataproc storage bucket
resource "google_storage_bucket" "dataproc" {
  name     = "${local.project_id}-dataproc"
  location = "US"
}

resource "google_storage_bucket_iam_binding" "default-public" {
  bucket = google_storage_bucket.default.name
  role   = "roles/storage.objectViewer"
  members = [
    "allUsers"
  ]
}

output "bucket_name" {
  value = google_storage_bucket.default.name
}

// we create a new policy that allows developers to be editor, compute admin, and storage admin
locals {
  members = {
    for username in local.teams :
    username => "group:acl-dsgt-clef-${username}-2024@googlegroups.com"
  }
}

resource "google_project_iam_member" "project-viewer" {
  for_each = local.members
  project  = local.project_id
  role     = "roles/viewer"
  member   = each.value
}

resource "google_project_iam_member" "compute-admin" {
  for_each = local.members
  project  = local.project_id
  role     = "roles/compute.admin"
  member   = each.value
}

resource "google_project_iam_member" "service-account-user" {
  for_each = local.members
  project  = local.project_id
  role     = "roles/iam.serviceAccountUser"
  member   = each.value
}

resource "google_project_iam_member" "storage-viewer" {
  for_each = local.members
  project  = local.project_id
  role     = "roles/storage.objectViewer"
  member   = each.value
}

// grant members the ability to read in the project
resource "google_project_iam_member" "secrets-viewer" {
  for_each = local.members
  project  = local.project_id
  role     = "roles/secretmanager.secretAccessor"
  member   = each.value
}

// create a service account for label studio
resource "google_service_account" "label-studio" {
  account_id   = "label-studio"
  display_name = "Label Studio"
}

// give it permissions to read and write to storage buckets
resource "google_project_iam_member" "label-studio-storage" {
  project = local.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.label-studio.email}"
}

// service account token creator
resource "google_project_iam_member" "label-studio-token-creator" {
  project = local.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_service_account.label-studio.email}"
}

// output the account name
output "label-studio-service-account" {
  value = google_service_account.label-studio.email
}
