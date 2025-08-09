variable "project_id" {
  description = "GCP project ID"
  type        = string
  default     = "esg-dev-jahid"
}
variable "region" {
  description = "Default region for regional resources"
  type        = string
  default     = "europe-west2"
}
variable "bq_location" {
  description = "BigQuery dataset location"
  type        = string
  default     = "EU"
}
