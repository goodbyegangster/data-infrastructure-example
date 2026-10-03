output "dataform_repository_name" {
  description = "Dataform Repository名"
  value       = google_dataform_repository.main.name
}

output "sakila_dataset_id" {
  description = "Dataform workflowの入力となるSakila検証用BigQuery dataset ID"
  value       = google_bigquery_dataset.sakila.dataset_id
}

output "dataform_output_dataset_id" {
  description = "Dataform workflowの出力先となるBigQuery dataset ID"
  value       = google_bigquery_dataset.dataform.dataset_id
}

output "dataform_assertion_dataset_id" {
  description = "Dataform assertionの出力先となるBigQuery dataset ID"
  value       = google_bigquery_dataset.dataform_assertions.dataset_id
}

output "dataform_runtime_service_account_email" {
  description = "Dataform workflowを実行するService Accountのメールアドレス"
  value       = google_service_account.dataform_runtime.email
}

output "data_platform_admin_service_account_email" {
  description = "データプラットフォームを管理するService Accountのメールアドレス"
  value       = google_service_account.data_platform_admin.email
}
