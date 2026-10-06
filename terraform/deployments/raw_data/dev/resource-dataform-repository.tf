# Dataform Repository を作成する。
resource "google_dataform_repository" "main" {
  depends_on = [
    google_project_service.project["dataform.googleapis.com"],
    google_service_account_iam_member.dataform_service_agent_token_creator,
    google_service_account_iam_member.dataform_service_agent_user,
  ]

  project         = var.project_id
  region          = var.location
  name            = "raw-data-${var.environment}"
  display_name    = "raw-data-${var.environment}"
  service_account = google_service_account.dataform_runtime.email

  deletion_policy = "FORCE"

  # 手動設定となる GitHub Repository との連携設定は Terraform 管理外とする。
  lifecycle {
    ignore_changes = [git_remote_settings]
  }
}
