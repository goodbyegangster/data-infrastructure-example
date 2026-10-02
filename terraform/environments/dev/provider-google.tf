provider "google" {
  project = var.project_id_raw_data
}

provider "google-beta" {
  project = var.project_id_raw_data
}
