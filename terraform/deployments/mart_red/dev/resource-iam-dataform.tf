# Dataform サービスエージェントに service agent role を付与する。
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

# Dataform runtime サービスアカウントに Developer Connect 利用権限を付与する。
resource "google_project_iam_member" "dataform_runtime_git_access" {
  for_each = toset([
    "roles/developerconnect.gitProxyUser",
    "roles/developerconnect.tokenAccessor",
  ])
  depends_on = [google_project_service.project["developerconnect.googleapis.com"]]

  project = var.project_id
  role    = each.value
  member  = google_service_account.dataform_runtime.member
}
