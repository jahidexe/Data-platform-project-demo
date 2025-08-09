# Enable BigQuery API
resource "google_project_service" "bigquery" {
  project = var.project_id
  service = "bigquery.googleapis.com"
}

module "bronze_root" {
  source  = "terraform-google-modules/bigquery/google"
  version = "~> 10.1" # your example shows ~> 9.0; 10.x works too

  project_id                 = var.project_id
  location                   = var.bq_location
  dataset_id                 = "bronze"
  dataset_name               = "bronze"
  description                = "Raw landing zone (Bronze)"
  delete_contents_on_destroy = true # dev only

  # Create a tiny table to prove module works
  tables = [
    {
      table_id           = "healthcheck"
      schema             = file("${path.module}/schemas/healthcheck.json")
      time_partitioning  = null
      range_partitioning = null
      expiration_time    = null
      clustering         = []
      labels = {
        env   = var.env
        layer = "bronze"
      }
    }
  ]

  dataset_labels = {
    env   = var.env
    layer = "bronze"
    app   = "data-platform-project-demo"
  }

  depends_on = [google_project_service.bigquery]
}
