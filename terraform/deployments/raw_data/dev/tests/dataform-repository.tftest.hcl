# Google Cloud へ接続せず、Google Provider の schema を使って Dataform Repository の plan を検証する。
mock_provider "google" {
  override_during = plan

  # Dataform サービスエージェントの ID を組み立てる project number を固定する。
  mock_data "google_project" {
    defaults = {
      number = "123456789012"
    }
  }

  # Repository に設定する runtime Service Account の computed 値を固定する。
  mock_resource "google_service_account" {
    defaults = {
      email  = "dataform-runtime-dev@example-project.iam.gserviceaccount.com"
      member = "serviceAccount:dataform-runtime-dev@example-project.iam.gserviceaccount.com"
      name   = "projects/example-project/serviceAccounts/dataform-runtime-dev@example-project.iam.gserviceaccount.com"
    }
  }
}

variables {
  project_id  = "example-project"
  location    = "asia-northeast1"
  environment = "dev"
  suffix      = "sample"
}

# 対象 project と location に環境別の Dataform Repository が作成されることを検証する。
run "configures_dataform_repository" {
  command = plan

  # Repository ID に環境名が含まれることを保証する。
  assert {
    condition     = google_dataform_repository.main.name == "dataform-sample-dev"
    error_message = "The Dataform repository ID must include the environment name."
  }

  # Repository の表示名が Repository ID と一致することを保証する。
  assert {
    condition     = google_dataform_repository.main.display_name == google_dataform_repository.main.name
    error_message = "The Dataform repository display name must match its repository ID."
  }

  # Repository が指定した project と location に作成されることを保証する。
  assert {
    condition = (
      google_dataform_repository.main.project == var.project_id &&
      google_dataform_repository.main.region == var.location
    )
    error_message = "The Dataform repository must be created in the target project and location."
  }

  # Workflow の実行主体に専用の runtime Service Account が指定されることを保証する。
  assert {
    condition = google_dataform_repository.main.service_account == (
      "dataform-runtime-dev@example-project.iam.gserviceaccount.com"
    )
    error_message = "The Dataform repository must use the dedicated runtime service account."
  }

  # Terraform destroy で Repository と配下のリソースが削除されることを保証する。
  assert {
    condition     = google_dataform_repository.main.deletion_policy == "FORCE"
    error_message = "The Dataform repository and its child resources must be deleted by Terraform destroy."
  }
}
