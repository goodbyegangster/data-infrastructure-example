# Google Cloud へ接続せず、Google Provider の schema を使って BigQuery dataset の plan を検証する。
mock_provider "google" {
  # 参照元 Dataset を固定し、Google Cloud に接続せず配置先を確認する。
  mock_data "google_bigquery_dataset" {
    defaults = {
      location = "asia-northeast1"
    }
  }

  override_during = plan

  # Dataform サービスエージェントのIDを組み立てるproject numberを固定する。
  mock_data "google_project" {
    defaults = {
      number = "123456789012"
    }
  }

  # root module 内の IAM を plan できるように Service Account の computed 値を固定する。
  mock_resource "google_service_account" {
    defaults = {
      email  = "dataform-runtime-dev@example-project.iam.gserviceaccount.com"
      member = "serviceAccount:dataform-runtime-dev@example-project.iam.gserviceaccount.com"
      name   = "projects/example-project/serviceAccounts/dataform-runtime-dev@example-project.iam.gserviceaccount.com"
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

# mart 用、assertion 用の BigQuery Dataset が作成されることを検証する。
run "configures_dataform_datasets" {
  command = plan

  # 用途ごとに固定した2つの dataset ID が使われることを保証する。
  assert {
    condition = toset(values(module.bigquery_datasets.dataset_ids)) == toset([
      "mart_red_sample_dev",
      "dataform_assertions_sample_dev",
    ])
    error_message = "The mart and assertion datasets must be created."
  }
}

# BigQuery で使用できないハイフンが dataset ID ではアンダースコアへ変換されることを検証する。
run "normalizes_dataset_name_components" {
  command = plan

  variables {
    environment = "dev-env"
    suffix      = "sample-a"
  }

  # suffix と環境名のハイフンが dataset ID で変換されることを保証する。
  assert {
    condition = toset(values(module.bigquery_datasets.dataset_ids)) == toset([
      "mart_red_sample_a_dev_env",
      "dataform_assertions_sample_a_dev_env",
    ])
    error_message = "Hyphens in dataset name components must be normalized to underscores."
  }
}

# 参照元と出力先の BigQuery Location が異なる構成を拒否する。
run "rejects_different_bigquery_locations" {
  command = plan

  variables {
    location = "us-central1"
  }

  expect_failures = [data.google_bigquery_dataset.sakila_staging]
}
