# Enable BigQuery API
resource "google_project_service" "bigquery" {
  project = var.project_id
  service = "bigquery.googleapis.com"
}

module "bronze_root" {
  source  = "terraform-google-modules/bigquery/google"
  version = "~> 10.1"

  dataset_id                 = "bronze"
  dataset_name               = "bronze"
  description                = "Bronze layer for raw ingested data"
  project_id                 = var.project_id
  location                   = var.bq_location
  delete_contents_on_destroy = false

  dataset_labels = {
    env   = var.env
    owner = "data-platform"
  }
}
