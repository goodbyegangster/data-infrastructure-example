# Raw Data Project の既存 staging Dataset と配置先を確認する。
data "google_bigquery_dataset" "sakila_staging" {
  project    = var.raw_data_project_id
  dataset_id = var.raw_data_staging_dataset_id

  lifecycle {
    postcondition {
      condition     = self.location == var.location
      error_message = "The staging and mart datasets must use the same BigQuery location."
    }
  }
}
