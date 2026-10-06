# Google Cloud へ接続せず、Google Provider の schema を使って plan を検証する。
mock_provider "google" {}

variables {
  project_id  = "example-project"
  location    = "asia-northeast1"
  environment = "dev"
  suffix      = "sample"
}

# Dataform runtime Service Account が運用方針どおりに構成されることを検証する。
run "configures_dataform_runtime_service_account" {
  command = plan

  # 環境を識別できる Service Account ID になることを保証する。
  assert {
    condition     = google_service_account.dataform_runtime.account_id == "dataform-runtime-dev"
    error_message = "The Dataform runtime service account ID must include the environment name."
  }

  # Terraform の対象 project に Service Account が作成されることを保証する。
  assert {
    condition     = google_service_account.dataform_runtime.project == var.project_id
    error_message = "The Dataform runtime service account must be created in the target project."
  }

  # Terraform destroy で Service Account が削除されることを保証する。
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
