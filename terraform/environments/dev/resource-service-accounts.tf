# Dataform workflowを実行するための専用Service Accountを作成する。
resource "google_service_account" "dataform_runtime" {
  depends_on = [google_project_service.workload["iam.googleapis.com"]]

  account_id      = "dataform-runtime-${var.environment}"
  deletion_policy = "DELETE"
  display_name    = "Dataform runtime (${var.environment})"
  description     = "Executes Dataform workflows in the ${var.environment} environment."
  project         = var.project_id_raw_data
}

# BigQuery datasetを管理するService Accountを作成する。
resource "google_service_account" "data_platform_admin" {
  depends_on = [google_project_service.workload["iam.googleapis.com"]]

  account_id      = "data-platform-admin-${var.environment}"
  deletion_policy = "DELETE"
  display_name    = "Data platform admin (${var.environment})"
  description     = "Owns the data platform datasets in the ${var.environment} environment."
  project         = var.project_id_raw_data
}

# Dataformサービスエージェントを生成する。
resource "google_workload_identity_service_agent" "dataform_service_agent" {
  depends_on = [
    google_project_service.workload["dataform.googleapis.com"],
    google_project_service.workload["workloadidentity.googleapis.com"],
  ]

  parent = "projects/${data.google_project.current.number}/locations/global/serviceProducers/dataform.googleapis.com"
}
