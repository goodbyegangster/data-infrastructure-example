# Dataformのworkflowを管理するRepositoryを作成する。
resource "google_dataform_repository" "main" {
  depends_on = [
    google_project_service.workload["dataform.googleapis.com"],
    google_service_account_iam_member.dataform_service_agent_token_creator,
    google_service_account_iam_member.dataform_service_agent_user,
  ]

  project         = var.project_id
  region          = var.location
  name            = "dataform-sample-${var.environment}"
  display_name    = "dataform-sample-${var.environment}"
  service_account = google_service_account.dataform_runtime.email
  deletion_policy = "FORCE"
}
