# main branch を環境別設定でコンパイルする Dataform Release configuration を作成する。
resource "google_dataform_repository_release_config" "main" {
  provider = google-beta

  project    = google_dataform_repository.main.project
  region     = google_dataform_repository.main.region
  repository = google_dataform_repository.main.name

  name          = "release-${var.environment}"
  git_commitish = "main"
  disabled      = false

  deletion_policy = "DELETE"

  code_compilation_config {
    default_database = google_bigquery_dataset.dataform.project
    default_schema   = google_bigquery_dataset.dataform.dataset_id
    default_location = google_bigquery_dataset.dataform.location
    assertion_schema = google_bigquery_dataset.dataform_assertions.dataset_id

    vars = {
      executionEnvironment = var.environment
      sakilaProject        = google_bigquery_dataset.sakila.project
      sakilaDataset        = google_bigquery_dataset.sakila.dataset_id
      sakilaStagingDataset = google_bigquery_dataset.dataform.dataset_id
    }
  }
}
