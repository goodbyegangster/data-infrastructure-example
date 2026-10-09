output "mart_red_dataset_id" {
  description = "Mart Red 向け BigQuery Dataset ID"
  value       = module.bigquery_datasets.dataset_ids["mart_red"]
}

output "dataform_assertions_dataset_id" {
  description = "Dataform assertion 向け BigQuery Dataset ID"
  value       = module.bigquery_datasets.dataset_ids["dataform_assertions"]
}

output "dataform_repository_name" {
  description = "Dataform Repository 名"
  value       = google_dataform_repository.main.name
}

output "data_platform_admin_service_account_email" {
  description = "BigQuery Dataset Owner である Service Account のメールアドレス"
  value       = google_service_account.data_platform_admin.email
}

output "dataform_runtime_service_account_email" {
  description = "Raw Data の staging 読み取り権限を付与する Service Account のメールアドレス"
  value       = google_service_account.dataform_runtime.email
}
