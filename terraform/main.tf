# Enable BigQuery API (first run only)
resource "google_project_service" "bigquery" {
  project = var.project_id
  service = "bigquery.googleapis.com"
}

# Bronze dataset (EU) via community module
module "bq_bronze" {
  source  = "terraform-google-modules/bigquery/google//modules/dataset"
  version = "~> 10.0"

  project_id = var.project_id
  dataset_id = "bronze"
  location   = var.bq_location

  delete_contents_on_destroy = true # safe for dev; set false in prod

  labels = {
    env   = var.env
    layer = "bronze"
    app   = "data-platform-project-demo"
  }

  depends_on = [google_project_service.bigquery]
}
