output "raw_sakila_dataset_id" {
  description = "Sakila raw data 向け BigQuery Dataset ID"
  value       = module.bigquery_datasets.dataset_ids["raw_sakila"]
}

output "stg_sakila_dataset_id" {
  description = "Sakila staging data 向け BigQuery Dataset ID"
  value       = module.bigquery_datasets.dataset_ids["stg_sakila"]
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
  description = "Dataform workflow を実行する Service Account のメールアドレス"
  value       = google_service_account.dataform_runtime.email
}


