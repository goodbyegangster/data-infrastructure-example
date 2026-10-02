# Google Cloudへ接続せず、Google Providerのschemaを使ってIAMのplanを検証する。
mock_provider "google" {
  override_during = plan

  # DataformサービスエージェントのIDを組み立てるproject numberを固定する。
  mock_data "google_project" {
    defaults = {
      number = "123456789012"
    }
  }

  # IAMの付与先をplanで検証できるようにService Accountのcomputed値を固定する。
  mock_resource "google_service_account" {
    defaults = {
      member = "serviceAccount:dataform-runtime-dev@example-project.iam.gserviceaccount.com"
      name   = "projects/example-project/serviceAccounts/dataform-runtime-dev@example-project.iam.gserviceaccount.com"
    }
  }
}

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

# runtime Service AccountへBigQuery jobの実行権限が付与されることを検証する。
run "grants_bigquery_job_permission_to_runtime" {
  command = plan

  # BigQueryでquery jobを実行するためのproject roleが選択されることを保証する。
  assert {
    condition     = google_project_iam_member.dataform_runtime_job_user.role == "roles/bigquery.jobUser"
    error_message = "The Dataform runtime service account must have the BigQuery Job User role."
  }

  # 権限の付与先がDataform runtime Service Accountだけであることを保証する。
  assert {
    condition     = google_project_iam_member.dataform_runtime_job_user.member == google_service_account.dataform_runtime.member
    error_message = "The BigQuery Job User role must be granted to the Dataform runtime service account."
  }
}

# Dataform runtime Service AccountがSakila入力datasetを読み取れることを検証する。
run "grants_sakila_reading_to_dataform_runtime" {
  command = plan

  override_resource {
    target          = google_service_account.dataform_runtime
    override_during = plan
    values = {
      member = "serviceAccount:dataform-runtime-dev@example-project.iam.gserviceaccount.com"
      name   = "projects/example-project/serviceAccounts/dataform-runtime-dev@example-project.iam.gserviceaccount.com"
    }
  }

  # Sakila入力datasetではBigQuery Data Viewer roleが選択されることを保証する。
  assert {
    condition     = google_bigquery_dataset_iam_member.dataform_runtime_sakila_viewer.role == "roles/bigquery.dataViewer"
    error_message = "The Dataform runtime service account must have Data Viewer on the Sakila dataset."
  }

  # 読み取り権限をSakila入力datasetだけに付与することを保証する。
  assert {
    condition = (
      google_bigquery_dataset_iam_member.dataform_runtime_sakila_viewer.dataset_id
      == google_bigquery_dataset.sakila.dataset_id
    )
    error_message = "Sakila reading must be scoped to the Sakila input dataset."
  }

  # 権限の付与先がDataform runtime Service Accountだけであることを保証する。
  assert {
    condition = (
      google_bigquery_dataset_iam_member.dataform_runtime_sakila_viewer.member
      == "serviceAccount:dataform-runtime-dev@example-project.iam.gserviceaccount.com"
    )
    error_message = "Sakila reading must be granted to the Dataform runtime service account."
  }
}

# Dataform runtime Service Accountが両出力datasetを編集できることを検証する。
run "grants_dataset_editing_to_dataform_runtime" {
  command = plan

  override_resource {
    target          = google_service_account.dataform_runtime
    override_during = plan
    values = {
      member = "serviceAccount:dataform-runtime-dev@example-project.iam.gserviceaccount.com"
      name   = "projects/example-project/serviceAccounts/dataform-runtime-dev@example-project.iam.gserviceaccount.com"
    }
  }

  override_resource {
    target          = google_service_account.data_platform_admin
    override_during = plan
    values = {
      member = "serviceAccount:data-platform-admin-dev@example-project.iam.gserviceaccount.com"
    }
  }

  # 両datasetでBigQuery Data Editor roleが選択されることを保証する。
  assert {
    condition = toset([
      google_bigquery_dataset_iam_member.dataform_runtime_output_editor.role,
      google_bigquery_dataset_iam_member.dataform_runtime_assertions_editor.role,
    ]) == toset(["roles/bigquery.dataEditor"])
    error_message = "The Dataform runtime service account must have Data Editor on both output datasets."
  }

  # 権限の付与先がDataform runtime Service Accountだけであることを保証する。
  assert {
    condition = alltrue([
      for member in [
        google_bigquery_dataset_iam_member.dataform_runtime_output_editor.member,
        google_bigquery_dataset_iam_member.dataform_runtime_assertions_editor.member,
      ] : member == "serviceAccount:dataform-runtime-dev@example-project.iam.gserviceaccount.com"
    ])
    error_message = "Dataset editing must be granted to the Dataform runtime service account."
  }

  # Dataform出力用とassertion用の両datasetへ権限を付与することを保証する。
  assert {
    condition = toset([
      google_bigquery_dataset_iam_member.dataform_runtime_output_editor.dataset_id,
      google_bigquery_dataset_iam_member.dataform_runtime_assertions_editor.dataset_id,
      ]) == toset([
      google_bigquery_dataset.dataform.dataset_id,
      google_bigquery_dataset.dataform_assertions.dataset_id,
    ])
    error_message = "Dataset editing must cover the Dataform output and assertion datasets."
  }
}

# データプラットフォーム管理用Service Accountが全datasetを管理できることを検証する。
run "grants_dataset_ownership_to_data_platform_admin" {
  command = plan

  override_resource {
    target          = google_service_account.data_platform_admin
    override_during = plan
    values = {
      member = "serviceAccount:data-platform-admin-dev@example-project.iam.gserviceaccount.com"
    }
  }

  # 全datasetでBigQuery Data Owner roleが選択されることを保証する。
  assert {
    condition = toset([
      google_bigquery_dataset_iam_member.data_platform_admin_sakila_owner.role,
      google_bigquery_dataset_iam_member.data_platform_admin_dataform_owner.role,
      google_bigquery_dataset_iam_member.data_platform_admin_assertions_owner.role,
    ]) == toset(["roles/bigquery.dataOwner"])
    error_message = "The data platform admin must have the BigQuery Data Owner role on all datasets."
  }

  # 権限の付与先がデータプラットフォーム管理用Service Accountだけであることを保証する。
  assert {
    condition = alltrue([
      for member in [
        google_bigquery_dataset_iam_member.data_platform_admin_sakila_owner.member,
        google_bigquery_dataset_iam_member.data_platform_admin_dataform_owner.member,
        google_bigquery_dataset_iam_member.data_platform_admin_assertions_owner.member,
      ] : member == "serviceAccount:data-platform-admin-dev@example-project.iam.gserviceaccount.com"
    ])
    error_message = "Dataset ownership must be granted to the data platform admin service account."
  }

  # Sakila入力用、Dataform出力用、assertion用の全datasetへ権限を付与することを保証する。
  assert {
    condition = toset([
      google_bigquery_dataset_iam_member.data_platform_admin_sakila_owner.dataset_id,
      google_bigquery_dataset_iam_member.data_platform_admin_dataform_owner.dataset_id,
      google_bigquery_dataset_iam_member.data_platform_admin_assertions_owner.dataset_id,
      ]) == toset([
      google_bigquery_dataset.sakila.dataset_id,
      google_bigquery_dataset.dataform.dataset_id,
      google_bigquery_dataset.dataform_assertions.dataset_id,
    ])
    error_message = "Dataset ownership must cover the Sakila input, Dataform output, and assertion datasets."
  }
}

# Dataformサービスエージェントがruntime Service Accountを利用できることを検証する。
run "grants_runtime_access_to_dataform_service_agent" {
  command = plan

  # IAM付与前に対象projectのDataformサービスエージェントを生成することを保証する。
  assert {
    condition = google_workload_identity_service_agent.dataform_service_agent.parent == (
      "projects/123456789012/locations/global/serviceProducers/dataform.googleapis.com"
    )
    error_message = "The Dataform service agent must be generated before IAM roles are granted."
  }

  # 明示的に生成したサービスエージェントへDataform標準roleを付与することを保証する。
  assert {
    condition     = google_project_iam_member.dataform_service_agent.role == "roles/dataform.serviceAgent"
    error_message = "The Dataform service agent must have its standard service agent role."
  }

  # Dataformの実行に必要なtoken作成とService Account利用の両権限を保証する。
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

  # 権限を対象projectのDataformサービスエージェントだけに付与することを保証する。
  assert {
    condition = alltrue([
      for member in [
        google_service_account_iam_member.dataform_service_agent_token_creator.member,
        google_service_account_iam_member.dataform_service_agent_user.member,
      ] : member == "serviceAccount:service-123456789012@gcp-sa-dataform.iam.gserviceaccount.com"
    ])
    error_message = "Runtime access must be granted to the target project's Dataform service agent."
  }

  # project全体ではなく対象runtime Service Account上で権限を管理することを保証する。
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
