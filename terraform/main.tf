


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

########################################
# dbt runtime Service Account
########################################
resource "google_service_account" "dbt_sa" {
  project      = var.project_id
  account_id   = "dbt-sa"
  display_name = "dbt Runtime Service Account"
}

# dbt must be able to submit query jobs
resource "google_project_iam_member" "dbt_project_job_user" {
  project = var.project_id
  role    = "roles/bigquery.user"
  member  = "serviceAccount:${google_service_account.dbt_sa.email}"
}

########################################
# Dataset IAM (native, additive + predictable)
########################################
# CI pipeline SA can edit Bronze (for loads, schema changes if needed)
resource "google_bigquery_dataset_iam_member" "bronze_ci_editor" {
  dataset_id = "bronze"
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:github-ci-dppd@${var.project_id}.iam.gserviceaccount.com"
}

# dbt SA can read Bronze (to build Silver)
resource "google_bigquery_dataset_iam_member" "bronze_dbt_viewer" {
  dataset_id = "bronze"
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:${google_service_account.dbt_sa.email}"
}

# dbt SA can write to Silver (models)
resource "google_bigquery_dataset_iam_member" "silver_dbt_editor" {
  dataset_id = "silver"
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.dbt_sa.email}"

}
