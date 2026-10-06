# 必要となる Google Cloud API を有効化する。
resource "google_project_service" "workload" {
  for_each = toset([
    "bigquery.googleapis.com",
    "dataform.googleapis.com",
    "iam.googleapis.com",
    "secretmanager.googleapis.com",
    "workloadidentity.googleapis.com",
  ])

  project = var.project_id
  service = each.value

  disable_on_destroy = false
}
