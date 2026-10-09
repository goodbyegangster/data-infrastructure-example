# Google Cloud へ接続せず、Google Provider の schema を使って Dataform 構成の plan を検証する。
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

  # Repository と IAM の参照先を plan で検証できるように Service Account の computed 値を固定する。
  mock_resource "google_service_account" {
    defaults = {
      email  = "dataform-runtime-dev@example-project.iam.gserviceaccount.com"
      member = "serviceAccount:dataform-runtime-dev@example-project.iam.gserviceaccount.com"
      name   = "projects/example-project/serviceAccounts/dataform-runtime-dev@example-project.iam.gserviceaccount.com"
    }
  }
}

# Google Cloud へ接続せず、Google Beta Provider の schema を使って Dataform 構成を検証する。
mock_provider "google-beta" {
  override_during = plan

  # Workflow から参照する Release configuration ID を plan で検証できるように固定する。
  mock_resource "google_dataform_repository_release_config" {
    defaults = {
      id = "projects/example-project/locations/asia-northeast1/repositories/mart-red-dev/releaseConfigs/release-dev"
    }
  }
}

variables {
  project_id                  = "example-project"
  location                    = "asia-northeast1"
  environment                 = "dev"
  suffix                      = "sample"
  raw_data_project_id         = "example-raw-project"
  raw_data_staging_dataset_id = "stg_sakila_sample_dev"
}

# Repository・Release・Workflow configuration の一連の構成を検証する。
run "configures_dataform_repository" {
  command = plan

  # Repository が対象 Project と Location に環境別の名前で作成されることを保証する。
  assert {
    condition = (
      google_dataform_repository.main.name == "mart-red-dev" &&
      google_dataform_repository.main.display_name == google_dataform_repository.main.name &&
      google_dataform_repository.main.project == var.project_id &&
      google_dataform_repository.main.region == var.location
    )
    error_message = "The Dataform repository must follow the configured naming and location policy."
  }

  # Repository が専用 runtime Service Account を使用することを保証する。
  assert {
    condition = (
      google_dataform_repository.main.service_account ==
      "dataform-runtime-dev@example-project.iam.gserviceaccount.com" &&
      google_dataform_repository.main.deletion_policy == "FORCE"
    )
    error_message = "The Dataform repository must use the runtime service account and FORCE deletion policy."
  }

  # Release configuration が main branch と指定した BigQuery 出力先を使用することを保証する。
  assert {
    condition = (
      google_dataform_repository_release_config.main.git_commitish == "main" &&
      !google_dataform_repository_release_config.main.disabled &&
      google_dataform_repository_release_config.main.code_compilation_config[0].default_database ==
      var.project_id &&
      google_dataform_repository_release_config.main.code_compilation_config[0].default_schema ==
      module.bigquery_datasets.dataset_ids["mart_red"] &&
      google_dataform_repository_release_config.main.code_compilation_config[0].assertion_schema ==
      module.bigquery_datasets.dataset_ids["dataform_assertions"]
    )
    error_message = "The release configuration must compile main with the configured BigQuery settings."
  }

  # Workflow configuration が Release configuration と runtime Service Account を使用することを保証する。
  assert {
    condition = (
      google_dataform_repository_workflow_config.main.release_config ==
      google_dataform_repository_release_config.main.id &&
      google_dataform_repository_workflow_config.main.invocation_config[0].service_account ==
      "dataform-runtime-dev@example-project.iam.gserviceaccount.com" &&
      !google_dataform_repository_workflow_config.main.disabled
    )
    error_message = "The workflow configuration must execute the release with the runtime service account."
  }
}

# 参照元と出力先の Project・Dataset が混同されないことを検証する。
run "compiles_from_raw_staging_into_red_mart" {
  command = plan

  # Raw Project の staging を入力として、Mart Red Project へ出力することを保証する。
  assert {
    condition = (
      google_dataform_repository_release_config.main.code_compilation_config[0].vars["sakilaProject"] == var.raw_data_project_id &&
      google_dataform_repository_release_config.main.code_compilation_config[0].vars["sakilaStagingDataset"] == var.raw_data_staging_dataset_id &&
      google_dataform_repository_release_config.main.code_compilation_config[0].vars["martProject"] == var.project_id &&
      google_dataform_repository_release_config.main.code_compilation_config[0].vars["martDataset"] == "mart_red_sample_dev"
    )
    error_message = "The release must read raw staging and write the red mart in their respective projects."
  }
}
