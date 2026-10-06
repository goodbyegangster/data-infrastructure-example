# 明示的に生成した Dataform サービスエージェントへ標準の service agent role を付与する。
resource "google_project_iam_member" "dataform_service_agent" {
  depends_on = [google_workload_identity_service_agent.dataform_service_agent]

  project = var.project_id
  role    = "roles/dataform.serviceAgent"
  member  = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-dataform.iam.gserviceaccount.com"
}

# Dataform サービスエージェントに Dataform runtime Service Account の token 作成権限を付与する。
resource "google_service_account_iam_member" "dataform_service_agent_token_creator" {
  depends_on = [google_project_iam_member.dataform_service_agent]

  service_account_id = google_service_account.dataform_runtime.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-dataform.iam.gserviceaccount.com"
}

# Dataform サービスエージェントに Dataform runtime Service Account の利用権限を付与する。
resource "google_service_account_iam_member" "dataform_service_agent_user" {
  depends_on = [google_project_iam_member.dataform_service_agent]

  service_account_id = google_service_account.dataform_runtime.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-dataform.iam.gserviceaccount.com"
}
