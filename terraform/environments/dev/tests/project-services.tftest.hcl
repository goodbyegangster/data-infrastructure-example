# Google Cloudへ接続せず、Google Providerのschemaを使ってplanを検証する。
mock_provider "google" {}

variables {
  project_id_raw_data  = "example-project"
  project_id_mart_red  = "example-project"
  project_id_mart_blue = "example-project"
  location_raw_data    = "asia-northeast1"
  location_mart_red    = "asia-northeast1"
  location_mart_blue   = "asia-northeast1"
  environment          = "dev"
  suffix               = "sample"
}

# workloadリソースに必要なGoogle Cloud APIの構成を検証する。
run "configures_workload_services" {
  command = plan

  # 必要なGoogle Cloud APIが過不足なく管理対象になっていることを保証する。
  assert {
    condition = toset(keys(google_project_service.workload)) == toset([
      "bigquery.googleapis.com",
      "dataform.googleapis.com",
      "iam.googleapis.com",
      "secretmanager.googleapis.com",
      "workloadidentity.googleapis.com",
    ])
    error_message = "The required workload APIs must be configured."
  }

  # Terraform管理から削除してもGoogle Cloud APIを無効化しないことを保証する。
  assert {
    condition = alltrue([
      for service in google_project_service.workload :
      service.disable_on_destroy == false
    ])
    error_message = "Workload APIs must remain enabled when removed from Terraform management."
  }
}
