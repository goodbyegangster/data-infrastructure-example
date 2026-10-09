# Dataform runtime Service Account に BigQuery job の実行権限を付与する。
resource "google_project_iam_member" "dataform_runtime_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = google_service_account.dataform_runtime.member
}
