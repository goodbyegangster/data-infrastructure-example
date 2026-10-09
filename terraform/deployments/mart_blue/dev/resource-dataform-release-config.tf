# 指定 ブランチをコンパイルする Dataform Release configuration を作成する。
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
    default_database = var.project_id
    default_schema   = module.bigquery_datasets.dataset_ids["mart_blue"]
    default_location = var.location
    assertion_schema = module.bigquery_datasets.dataset_ids["dataform_assertions"]

    vars = {
      executionEnvironment = var.environment
      sakilaProject        = data.google_bigquery_dataset.sakila_staging.project
      sakilaStagingDataset = data.google_bigquery_dataset.sakila_staging.dataset_id
      martProject          = var.project_id
      martDataset          = module.bigquery_datasets.dataset_ids["mart_blue"]
    }
  }
}
