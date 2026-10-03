# Google Cloudへ接続せず、Google Providerのschemaを使ってDataform Repositoryのplanを検証する。
mock_provider "google" {
  override_during = plan

  # DataformサービスエージェントのIDを組み立てるproject numberを固定する。
  mock_data "google_project" {
    defaults = {
      number = "123456789012"
    }
  }

  # Repositoryに設定するruntime Service Accountのcomputed値を固定する。
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

# 対象projectとlocationに環境別のDataform Repositoryが作成されることを検証する。
run "configures_dataform_repository" {
  command = plan

  # Repository IDに環境名が含まれることを保証する。
  assert {
    condition     = google_dataform_repository.main.name == "dataform-sample-dev"
    error_message = "The Dataform repository ID must include the environment name."
  }

  # Repositoryの表示名がRepository IDと一致することを保証する。
  assert {
    condition     = google_dataform_repository.main.display_name == google_dataform_repository.main.name
    error_message = "The Dataform repository display name must match its repository ID."
  }

  # Repositoryが指定したprojectとlocationに作成されることを保証する。
  assert {
    condition = (
      google_dataform_repository.main.project == var.project_id &&
      google_dataform_repository.main.region == var.location
    )
    error_message = "The Dataform repository must be created in the target project and location."
  }

  # Workflowの実行主体に専用のruntime Service Accountが指定されることを保証する。
  assert {
    condition = google_dataform_repository.main.service_account == (
      "dataform-runtime-dev@example-project.iam.gserviceaccount.com"
    )
    error_message = "The Dataform repository must use the dedicated runtime service account."
  }

  # Terraform destroyでRepositoryと配下の子リソースが削除されることを保証する。
  assert {
    condition     = google_dataform_repository.main.deletion_policy == "FORCE"
    error_message = "The Dataform repository and its child resources must be deleted by Terraform destroy."
  }
}
