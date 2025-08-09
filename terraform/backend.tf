terraform {
  backend "gcs" {
    bucket = "tf-backend-esg-dev-jahid"
    prefix = "data-platform-project-demo/state"
  }
}
