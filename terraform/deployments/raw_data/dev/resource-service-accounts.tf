# BigQuery dataset の OWNER となる Service Account を作成する。
resource "google_service_account" "data_platform_admin" {
  depends_on = [google_project_service.project["iam.googleapis.com"]]

  project      = var.project_id
  account_id   = "data-platform-admin-${var.environment}"
  display_name = "Data platform admin (${var.environment})"
  description  = "Owns the data platform datasets in the ${var.environment} environment."

  deletion_policy = "DELETE"
}

# Dataform workflow を実行するための専用 Service Account を作成する。
resource "google_service_account" "dataform_runtime" {
  depends_on = [google_project_service.project["iam.googleapis.com"]]

  project      = var.project_id
  account_id   = "dataform-runtime-${var.environment}"
  display_name = "Dataform runtime (${var.environment})"
  description  = "Executes Dataform workflows in the ${var.environment} environment."

  deletion_policy = "DELETE"
}

# Dataform サービスエージェントを生成する。
resource "google_workload_identity_service_agent" "dataform_service_agent" {
  depends_on = [
    google_project_service.project["dataform.googleapis.com"],
    google_project_service.project["workloadidentity.googleapis.com"],
  ]

  parent = "projects/${data.google_project.current.number}/locations/global/serviceProducers/dataform.googleapis.com"
}
