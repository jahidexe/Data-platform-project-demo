resource "google_project_service" "bigquery" {
  project = var.project_id
  service = "bigquery.googleapis.com"
}

module "bq_bronze" {
  source  = "terraform-google-modules/bigquery/google//modules/dataset"
  version = "~> 10.0"

  project_id = var.project_id
  dataset_id = "bronze"
  location   = var.bq_location

  delete_contents_on_destroy = true
  labels = {
    env   = var.env
    layer = "bronze"
  }

  depends_on = [google_project_service.bigquery]
}
