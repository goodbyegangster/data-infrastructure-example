# Dataform Workflow configuration を作成する。
resource "google_dataform_repository_workflow_config" "main" {
  provider = google-beta

  project    = google_dataform_repository.main.project
  region     = google_dataform_repository.main.region
  repository = google_dataform_repository.main.name

  name           = "workflow-${var.environment}"
  release_config = google_dataform_repository_release_config.main.id
  disabled       = false

  deletion_policy = "DELETE"

  invocation_config {
    service_account = google_service_account.dataform_runtime.email
  }
}
