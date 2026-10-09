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
  project_id                  = "example-project"
  location                    = "asia-northeast1"
  environment                 = "dev"
  suffix                      = "sample"
  raw_data_project_id         = "example-raw-project"
  raw_data_staging_dataset_id = "stg_sakila_sample_dev"
}

# Dataform runtime と BigQuery Dataset Owner 用 Service Account の構成を検証する。
run "configures_service_accounts" {
  command = plan

  # Dataform runtime Service Account ID に環境名が含まれることを保証する。
  assert {
    condition     = google_service_account.dataform_runtime.account_id == "dataform-runtime-dev"
    error_message = "The Dataform runtime service account ID must include the environment name."
  }

  # Dataform runtime Service Account が対象 Project に作成されることを保証する。
  assert {
    condition     = google_service_account.dataform_runtime.project == var.project_id
    error_message = "The Dataform runtime service account must be created in the target project."
  }

  # Terraform destroy で Dataform runtime Service Account が削除されることを保証する。
  assert {
    condition     = google_service_account.dataform_runtime.deletion_policy == "DELETE"
    error_message = "The Dataform runtime service account must be deleted by Terraform destroy."
  }

  # BigQuery Dataset Owner 用 Service Account ID に環境名が含まれることを保証する。
  assert {
    condition     = google_service_account.data_platform_admin.account_id == "data-platform-admin-dev"
    error_message = "The data platform admin service account ID must include the environment name."
  }

  # BigQuery Dataset Owner 用 Service Account が対象 project に作成されることを保証する。
  assert {
    condition     = google_service_account.data_platform_admin.project == var.project_id
    error_message = "The data platform admin service account must be created in the target project."
  }

  # Terraform destroy で検証用の管理 Service Account が削除されることを保証する。
  assert {
    condition     = google_service_account.data_platform_admin.deletion_policy == "DELETE"
    error_message = "The data platform admin service account must be deleted by Terraform destroy."
  }
}

# Service Account ID 名長の上限を超える environment 名が拒否されることを検証する。
run "rejects_environment_too_long_for_service_account_id" {
  command = plan

  variables {
    environment = "environment-too-long"
  }

  expect_failures = [var.environment]
}
