


resource "google_project_service" "bigquery" {
  project            = var.project_id
  service            = "bigquery.googleapis.com"
  disable_on_destroy = false
}


########################################
# Datasets via ROOT module (no tables yet)
########################################
module "bronze_root" {
  source  = "terraform-google-modules/bigquery/google"
  version = "~> 10.1"

  project_id                 = var.project_id
  dataset_id                 = "bronze"
  dataset_name               = "bronze"
  location                   = var.bq_location
  description                = "Raw landing zone (Bronze)"
  delete_contents_on_destroy = true # prod: set to false
  dataset_labels = {
    env   = var.env
    layer = "bronze"
    app   = "data-platform-project-demo"
  }

  # no tables/views yet; dbt will own them
  tables = []
  views  = []
}

module "silver_root" {
  source  = "terraform-google-modules/bigquery/google"
  version = "~> 10.1"

  project_id                 = var.project_id
  dataset_id                 = "silver"
  dataset_name               = "silver"
  location                   = var.bq_location
  description                = "Curated cleansed layer (Silver)"
  delete_contents_on_destroy = true
  dataset_labels = {
    env   = var.env
    layer = "silver"
    app   = "data-platform-project-demo"
  }

  tables = []
  views  = []
}
