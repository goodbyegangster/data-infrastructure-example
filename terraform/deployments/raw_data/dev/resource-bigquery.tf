# Dataform workflowの入力となるSakila検証用BigQuery datasetを作成する。
resource "google_bigquery_dataset" "sakila" {
  depends_on = [google_project_service.workload["bigquery.googleapis.com"]]

  project                    = var.project_id
  dataset_id                 = "sakila_${replace(var.suffix, "-", "_")}_${replace(var.environment, "-", "_")}"
  friendly_name              = "sakila_${replace(var.suffix, "-", "_")}_${replace(var.environment, "-", "_")}"
  description                = "Stores Sakila source data used to validate Dataform workflows."
  location                   = var.location
  delete_contents_on_destroy = true
  deletion_policy            = "DELETE"
}

# Dataform workflowの出力先となるBigQuery datasetを作成する。
resource "google_bigquery_dataset" "dataform" {
  depends_on = [google_project_service.workload["bigquery.googleapis.com"]]

  project                    = var.project_id
  dataset_id                 = "dataform_${replace(var.suffix, "-", "_")}_${replace(var.environment, "-", "_")}"
  friendly_name              = "dataform_${replace(var.suffix, "-", "_")}_${replace(var.environment, "-", "_")}"
  description                = "Stores tables and views created by Dataform workflows."
  location                   = var.location
  delete_contents_on_destroy = true
  deletion_policy            = "DELETE"
}

# Dataform assertionの結果を保持するBigQuery datasetを作成する。
resource "google_bigquery_dataset" "dataform_assertions" {
  depends_on = [google_project_service.workload["bigquery.googleapis.com"]]

  project                    = var.project_id
  dataset_id                 = "dataform_assertions_${replace(var.suffix, "-", "_")}_${replace(var.environment, "-", "_")}"
  friendly_name              = "dataform_assertions_${replace(var.suffix, "-", "_")}_${replace(var.environment, "-", "_")}"
  description                = "Stores assertion views created by Dataform workflows."
  location                   = var.location
  delete_contents_on_destroy = true
  deletion_policy            = "DELETE"
}
