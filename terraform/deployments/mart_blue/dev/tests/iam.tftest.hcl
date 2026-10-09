# Google Cloud へ接続せず、Google Provider の schema を使って IAM の plan を検証する。
mock_provider "google" {
  # 参照元 Dataset を固定し、Google Cloud に接続せず配置先を確認する。
  mock_data "google_bigquery_dataset" {
    defaults = {
      location = "asia-northeast1"
    }
  }

  override_during = plan

  # Dataform サービスエージェントの ID を組み立てる Project number を固定する。
  mock_data "google_project" {
    defaults = {
      number = "123456789012"
    }
  }

  # IAM の付与先を plan で検証できるように Service Account の computed 値を固定する。
  mock_resource "google_service_account" {
    defaults = {
      member = "serviceAccount:dataform-runtime-dev@example-blue-project.iam.gserviceaccount.com"
      name   = "projects/example-blue-project/serviceAccounts/dataform-runtime-dev@example-blue-project.iam.gserviceaccount.com"
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

# Dataform runtime Service Account へ BigQuery job の実行権限が付与されることを検証する。
run "grants_bigquery_job_permission_to_runtime" {
  command = plan

  # BigQuery で query job を実行するための Project role が選択されることを保証する。
  assert {
    condition     = google_project_iam_member.dataform_runtime_job_user.role == "roles/bigquery.jobUser"
    error_message = "The Dataform runtime service account must have the BigQuery Job User role."
  }

  # 権限の付与先が Dataform runtime Service Account だけであることを保証する。
  assert {
    condition = (
      google_project_iam_member.dataform_runtime_job_user.member ==
      google_service_account.dataform_runtime.member
    )
    error_message = "The BigQuery Job User role must be granted to the Dataform runtime service account."
  }
}

# Dataform サービスエージェントが runtime Service Account を利用できることを検証する。
run "grants_runtime_access_to_dataform_service_agent" {
  command = plan

  # IAM 付与前に対象 Project の Dataform サービスエージェントを生成することを保証する。
  assert {
    condition = google_workload_identity_service_agent.dataform_service_agent.parent == (
      "projects/123456789012/locations/global/serviceProducers/dataform.googleapis.com"
    )
    error_message = "The Dataform service agent must be generated before IAM roles are granted."
  }

  # 明示的に生成したサービスエージェントへ Dataform 標準 role を付与することを保証する。
  assert {
    condition     = google_project_iam_member.dataform_service_agent.role == "roles/dataform.serviceAgent"
    error_message = "The Dataform service agent must have its standard service agent role."
  }

  # Dataform の実行に必要な token 作成と Service Account 利用の両権限を保証する。
  assert {
    condition = toset([
      google_service_account_iam_member.dataform_service_agent_token_creator.role,
      google_service_account_iam_member.dataform_service_agent_user.role,
      ]) == toset([
      "roles/iam.serviceAccountTokenCreator",
      "roles/iam.serviceAccountUser",
    ])
    error_message = "The Dataform service agent must be able to impersonate the runtime service account."
  }

  # 権限を対象 Project の Dataform サービスエージェントだけに付与することを保証する。
  assert {
    condition = alltrue([
      for member in [
        google_service_account_iam_member.dataform_service_agent_token_creator.member,
        google_service_account_iam_member.dataform_service_agent_user.member,
      ] : member == "serviceAccount:service-123456789012@gcp-sa-dataform.iam.gserviceaccount.com"
    ])
    error_message = "Runtime access must be granted to the target project's Dataform service agent."
  }

  # Project 全体ではなく対象 runtime Service Account 上で権限を管理することを保証する。
  assert {
    condition = alltrue([
      for service_account_id in [
        google_service_account_iam_member.dataform_service_agent_token_creator.service_account_id,
        google_service_account_iam_member.dataform_service_agent_user.service_account_id,
      ] : service_account_id == google_service_account.dataform_runtime.name
    ])
    error_message = "Dataform service agent roles must be scoped to the runtime service account."
  }
}
