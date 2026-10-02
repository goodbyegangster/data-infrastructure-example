# Dataform runtime Service AccountにBigQuery jobの実行権限を付与する。
resource "google_project_iam_member" "dataform_runtime_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = google_service_account.dataform_runtime.member
}

# Dataform runtime Service AccountにSakila入力datasetの読み取り権限を付与する。
resource "google_bigquery_dataset_iam_member" "dataform_runtime_sakila_viewer" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.sakila.dataset_id
  role       = "roles/bigquery.dataViewer"
  member     = google_service_account.dataform_runtime.member
}

# Dataform runtime Service Accountにdatasetの編集権限を付与する。
resource "google_bigquery_dataset_iam_member" "dataform_runtime_output_editor" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.dataform.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = google_service_account.dataform_runtime.member
}

# Dataform runtime Service Accountにdataform assertion向けdatasetの編集権限を付与する。
resource "google_bigquery_dataset_iam_member" "dataform_runtime_assertions_editor" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.dataform_assertions.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = google_service_account.dataform_runtime.member
}

# データプラットフォーム管理用Service AccountをDataform出力datasetのOwnerにする。
resource "google_bigquery_dataset_iam_member" "data_platform_admin_dataform_owner" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.dataform.dataset_id
  role       = "roles/bigquery.dataOwner"
  member     = google_service_account.data_platform_admin.member
}

# データプラットフォーム管理用Service Accountをassertion datasetのOwnerにする。
resource "google_bigquery_dataset_iam_member" "data_platform_admin_assertions_owner" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.dataform_assertions.dataset_id
  role       = "roles/bigquery.dataOwner"
  member     = google_service_account.data_platform_admin.member
}

# データプラットフォーム管理用Service AccountをSakila入力datasetのOwnerにする。
resource "google_bigquery_dataset_iam_member" "data_platform_admin_sakila_owner" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.sakila.dataset_id
  role       = "roles/bigquery.dataOwner"
  member     = google_service_account.data_platform_admin.member
}
