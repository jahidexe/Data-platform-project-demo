resource "google_project_service" "bigquery" {
  project              = var.project_id
  service              = "bigquery.googleapis.com"
  disable_on_destroy   = false   # <— IMPORTANT
}
