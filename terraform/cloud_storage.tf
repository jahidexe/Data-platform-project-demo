resource "google_storage_bucket" "raw_ingest" {
  name                        = "${var.project_id}-raw-${var.env}"
  location                    = var.bq_location
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  force_destroy               = true # prod: false

  labels = {
    env   = var.env
    layer = "raw"
  }
}

# CI SA can write to the bucket
resource "google_storage_bucket_iam_member" "ci_raw_writer" {
  bucket = google_storage_bucket.raw_ingest.name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:github-ci-dppd@${var.project_id}.iam.gserviceaccount.com"
}

# Optional: dbt SA can read raw files
resource "google_storage_bucket_iam_member" "dbt_raw_reader" {
  bucket = google_storage_bucket.raw_ingest.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:dbt-sa@${var.project_id}.iam.gserviceaccount.com"
}
