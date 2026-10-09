# Google Cloud へ接続せず、Google Provider の schema を使って plan を検証する。
mock_provider "google" {
  # 参照元 Dataset を固定し、Google Cloud に接続せず配置先を確認する。
  mock_data "google_bigquery_dataset" {
    defaults = {
      location = "asia-northeast1"
    }
  }

  # Dataform サービスエージェントの ID を組み立てる Project number を固定する。
  mock_data "google_project" {
    defaults = {
      number = "123456789012"
    }
  }
}

# Google Cloud へ接続せず、Google Beta Provider を使用するリソースも plan できるようにする。
mock_provider "google-beta" {}

variables {
  project_id                  = "example-blue-project"
  location                    = "asia-northeast1"
  environment                 = "dev"
  suffix                      = "sample"
  raw_data_project_id         = "example-raw-project"
  raw_data_staging_dataset_id = "stg_sakila_sample_dev"
}

# workload リソースに必要な Google Cloud API の構成を検証する。
run "configures_workload_services" {
  command = plan

  # 必要な Google Cloud API が過不足なく管理対象になっていることを保証する。
  assert {
    condition = toset(keys(google_project_service.project)) == toset([
      "bigquery.googleapis.com",
      "dataform.googleapis.com",
      "iam.googleapis.com",
      "secretmanager.googleapis.com",
      "workloadidentity.googleapis.com",
    ])
    error_message = "The required workload APIs must be configured."
  }

  # Terraform 管理から削除しても Google Cloud API を無効化しないことを保証する。
  assert {
    condition = alltrue([
      for service in google_project_service.project :
      service.disable_on_destroy == false
    ])
    error_message = "Workload APIs must remain enabled when removed from Terraform management."
  }
}
