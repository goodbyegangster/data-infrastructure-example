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

# Dataform runtime Service Accountが運用方針どおりに構成されることを検証する。
run "configures_dataform_runtime_service_account" {
  command = plan

  # 環境を識別できるService Account IDになることを保証する。
  assert {
    condition     = google_service_account.dataform_runtime.account_id == "dataform-runtime-dev"
    error_message = "The Dataform runtime service account ID must include the environment name."
  }

  # Terraformの対象projectにService Accountが作成されることを保証する。
  assert {
    condition     = google_service_account.dataform_runtime.project == var.project_id_raw_data
    error_message = "The Dataform runtime service account must be created in the target project."
  }

  # Terraform destroyで検証用Service Accountが削除されることを保証する。
  assert {
    condition     = google_service_account.dataform_runtime.deletion_policy == "DELETE"
    error_message = "The Dataform runtime service account must be deleted by Terraform destroy."
  }

  # データプラットフォーム管理用Service Account IDに環境名が含まれることを保証する。
  assert {
    condition     = google_service_account.data_platform_admin.account_id == "data-platform-admin-dev"
    error_message = "The data platform admin service account ID must include the environment name."
  }

  # データプラットフォーム管理用Service Accountが対象projectに作成されることを保証する。
  assert {
    condition     = google_service_account.data_platform_admin.project == var.project_id_raw_data
    error_message = "The data platform admin service account must be created in the target project."
  }

  # Terraform destroyで検証用の管理Service Accountが削除されることを保証する。
  assert {
    condition     = google_service_account.data_platform_admin.deletion_policy == "DELETE"
    error_message = "The data platform admin service account must be deleted by Terraform destroy."
  }
}

# Service Account IDの上限を超えるenvironmentが拒否されることを検証する。
run "rejects_environment_too_long_for_service_account_id" {
  command = plan

  variables {
    environment = "environment-too-long"
  }

  expect_failures = [var.environment]
}
