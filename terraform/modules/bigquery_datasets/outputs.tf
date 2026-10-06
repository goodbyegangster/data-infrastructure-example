output "dataset_ids" {
  description = "BigQuery Dataset ID"
  value = {
    for name, dataset in google_bigquery_dataset.managed :
    name => dataset.dataset_id
  }
}
