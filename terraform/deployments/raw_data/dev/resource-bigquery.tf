# Raw Data Project で使用する BigQuery Dataset を作成する。
module "bigquery_datasets" {
  depends_on = [google_project_service.project["bigquery.googleapis.com"]]

  source = "../../../modules/bigquery_datasets"

  project_id             = var.project_id
  location               = var.location
  environment            = var.environment
  suffix                 = var.suffix
  owner_email            = google_service_account.data_platform_admin.email
  dataform_runtime_email = google_service_account.dataform_runtime.email

  datasets = {
    raw_sakila = {
      description  = "Sakila raw data."
      runtime_role = "READER"
    }
    stg_sakila = {
      description  = "Sakila staging data."
      runtime_role = "WRITER"
    }
    dataform_assertions = {
      description  = "Dataform assertion data."
      runtime_role = "WRITER"
    }
  }
}
