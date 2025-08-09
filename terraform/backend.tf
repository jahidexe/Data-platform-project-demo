terraform {
  backend "gcs" {
    bucket = "tf-backend-esg-dev-jahid"  # <-- ensure this bucket exists
    prefix = "state"
  }
}
