
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
